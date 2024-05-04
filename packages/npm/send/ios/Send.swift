private let CODE_REQUEST_INVALID = "@candlefinance.send.request_invalid"
private let CODE_NO_RESPONSE = "@candlefinance.send.no_response"
private let CODE_RESPONSE_INVALID = "@candlefinance.send.response_invalid"
private let CODE_UNKNOWN = "@candlefinance.send.unknown"

private let MESSAGE_REQUEST_INVALID =
"Your request is invalid. Please verify the format of your base URL and any other fields specified."
private let MESSAGE_NO_RESPONSE =
"Your request did not receive a response. Please verify your Internet connection."
private let MESSAGE_RESPONSE_INVALID =
"Your request received a response, but it couldn't be processed. Please verify the configuration of your server."
private let MESSAGE_UNKNOWN = "Something went wrong. Please file an issue on GitHub or try again."

private func bodyIsUTF8(contentTypeHeader: String?, utf8ContentTypes: [String]) -> Bool {
    guard let contentType = contentTypeHeader?.split(separator: ";").first else {
        return false
    }
    return utf8ContentTypes.contains(String(contentType))
}

enum SendError: Error {
    case nonBase64RequestBody
    
    case nonUTF8RequestBody
    case nonUTF8ResponseBody
    
    case invalidRequestBaseURL
    case invalidRequestPathOrQueryParameters
    case invalidResponseHeaderParameters
    
    var message: String {
        switch self {
        case .nonBase64RequestBody:
            return "Your request headers specify a Content-Type NOT included in `utf8ContentTypes`, but your request body is not a base64-encoded string."
        case .nonUTF8RequestBody:
            return "Your request headers specify a Content-Type included in `utf8ContentTypes`, but your request body is not a UTF8-encoded string."
        case .nonUTF8ResponseBody:
            return "The response headers specify a Content-Type included in `utf8ContentTypes`, but the response body was not UTF8-encoded."
            
        case .invalidRequestBaseURL:
            return "Your base URL is not valid."
        case .invalidRequestPathOrQueryParameters:
            return "Your path or query parameters is not valid."
        case .invalidResponseHeaderParameters:
            return "The response headers were not valid."
            
        }
    }
}

@propertyWrapper
struct RequiredKey<Value> {
    var wrappedValue: Value?
}

extension RequiredKey: Decodable where Value: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = container.decodeNil() ? nil : try container.decode(Value.self)
    }
}

extension RequiredKey: Encodable where Value: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

struct Request: Decodable {
    let baseURL: String
    let path: String
    let queryParameters: [String: String]
    let headerParameters: [String: String]
    let method: String
    @RequiredKey var body: String?
    let utf8ContentTypes: [String]
    
    var url: Result<URL, SendError> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return .failure(.invalidRequestBaseURL)
        }
        urlComponents.path = path
        
        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            return .failure(.invalidRequestPathOrQueryParameters)
        }
        return .success(url)
    }
    
    var urlRequest: Result<URLRequest, SendError> {
        return url.flatMap { url in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            
            for (key, value) in headerParameters {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            if let body {
                let contentTypeHeader = headerParameters.first(where: { $0.key.caseInsensitiveCompare("Content-Type") == .orderedSame })?.value
                if bodyIsUTF8(contentTypeHeader: contentTypeHeader, utf8ContentTypes: utf8ContentTypes) {
                    guard let utf8Body = body.data(using: .utf8) else {
                        return .failure(.nonUTF8RequestBody)
                    }
                    urlRequest.httpBody = utf8Body
                } else {
                    guard let base64Body = Data(base64Encoded: body) else {
                        return .failure(.nonBase64RequestBody)
                    }
                    urlRequest.httpBody = base64Body
                }
            }
            return .success(urlRequest)
        }
    }
}

struct Response: Encodable {
    let statusCode: Int
    let headerParameters: [String: String]
    @RequiredKey var body: String?
    
    init(request: Request, data: Data, httpURLResponse: HTTPURLResponse) throws {
        self.statusCode = httpURLResponse.statusCode
        
        guard let headerParameters = httpURLResponse.allHeaderFields as? [String: String] else {
            throw SendError.invalidResponseHeaderParameters
        }
        self.headerParameters = headerParameters
        
        if (data.isEmpty) {
            self.body = nil
        } else {
            let bodyIsUTF8 = bodyIsUTF8(
                contentTypeHeader: httpURLResponse.value(forHTTPHeaderField: "Content-Type"),
                utf8ContentTypes: request.utf8ContentTypes
            )
            if (bodyIsUTF8) {
                guard let utf8Body = String(data: data, encoding: .utf8) else {
                    throw SendError.nonUTF8ResponseBody
                }
                self.body = utf8Body
            } else {
                self.body = data.base64EncodedString()
            }
        }
    }
}

class IgnoreRedirectsDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        return nil
    }
}

@objc(Send)
class Send: NSObject {
    let session = URLSession(configuration: .default, delegate: IgnoreRedirectsDelegate(), delegateQueue: nil)
    
    @objc(send:withResolver:withRejecter:)
    @available(iOS 15.0, *)
    func send(
        stringifiedRequest: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        Task {
            do {
                guard let requestData = stringifiedRequest.data(using: .utf8) else {
                    return reject(CODE_REQUEST_INVALID, requestError, nil)
                }
                let request = try JSONDecoder().decode(Request.self, from: requestData)
                let urlRequest = try request.urlRequest.get()
                
                let (data, urlResponse) = try await session.data(for: urlRequest)
                guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                    reject(CODE_RESPONSE_INVALID, responseError, nil)
                    return
                }
                let response = try Response(
                    request: request,
                    data: data,
                    httpURLResponse: httpURLResponse
                )
                
                let responseData = try JSONEncoder().encode(response)
                guard let stringifiedResponse = String(data: responseData, encoding: .utf8) else {
                    return reject(CODE_RESPONSE_INVALID, responseError, nil)
                }
                resolve(stringifiedResponse)
                
            } catch let sendError as SendError {
                switch (sendError) {
                case .nonBase64RequestBody,
                        .invalidRequestBaseURL,
                        .nonUTF8RequestBody,
                        .invalidRequestPathOrQueryParameters:
                    reject(CODE_REQUEST_INVALID, sendError.message, sendError)
                    
                case .nonUTF8ResponseBody,
                        .invalidResponseHeaderParameters:
                    reject(CODE_RESPONSE_INVALID, sendError.message, sendError)
                }
                
            } catch let decodingError as DecodingError {
                reject(CODE_REQUEST_INVALID, decodingError.failureReason, decodingError)
                
            } catch let encodingError as EncodingError {
                reject(CODE_RESPONSE_INVALID, encodingError.failureReason, encodingError)
                
            } catch let urlError as URLError {
                switch (urlError.code) {
                case .appTransportSecurityRequiresSecureConnection,
                        .badURL,
                        .cancelled,
                        .cannotConnectToHost,
                        .cannotFindHost,
                        .clientCertificateRejected,
                        .clientCertificateRequired,
                        .dataLengthExceedsMaximum,
                        .dataNotAllowed,
                        .dnsLookupFailed,
                        .fileDoesNotExist,
                        .fileIsDirectory,
                        .noPermissionsToReadFile,
                        .requestBodyStreamExhausted,
                        .unsupportedURL,
                        .userAuthenticationRequired,
                        .userCancelledAuthentication:
                    reject(CODE_REQUEST_INVALID, MESSAGE_REQUEST_INVALID, urlError)
                    
                case  .callIsActive,
                        .internationalRoamingOff,
                        .networkConnectionLost,
                        .notConnectedToInternet,
                        .resourceUnavailable,
                        .serverCertificateHasBadDate,
                        .serverCertificateHasUnknownRoot,
                        .serverCertificateNotYetValid,
                        .serverCertificateUntrusted,
                        .secureConnectionFailed,
                        .timedOut,
                        .appTransportSecurityRequiresSecureConnection:
                    reject(CODE_NO_RESPONSE, MESSAGE_NO_RESPONSE, urlError)
                    
                case .backgroundSessionInUseByAnotherProcess,
                        .backgroundSessionRequiresSharedContainer,
                        .backgroundSessionWasDisconnected,
                        .badServerResponse,
                        .cannotCloseFile,
                        .cannotCreateFile,
                        .cannotDecodeContentData,
                        .cannotDecodeRawData,
                        .cannotMoveFile,
                        .cannotOpenFile,
                        .cannotParseResponse,
                        .cannotRemoveFile,
                        .cannotWriteToFile,
                        .downloadDecodingFailedMidStream,
                        .downloadDecodingFailedToComplete,
                        .httpTooManyRedirects,
                        .redirectToNonExistentLocation,
                        .zeroByteResource:
                    reject(CODE_RESPONSE_INVALID, MESSAGE_RESPONSE_INVALID, urlError)
                    
                default:
                    // NOTE: The only other documented case is `unknown`, but code is not an enum so a default case is required regardless
                    reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, urlError)
                }
            } catch let error {
                reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, error)
            }
        }
    }
}
