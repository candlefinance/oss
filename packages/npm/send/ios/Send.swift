private let requestError = "Your request was invalid. Please make sure it conforms to the Request type and try again."
private let serverError = "Your request did not receive a response. Please make sure you are connected to the Internet and try again."
private let responseError = "Your request received a response, but it couldn't be processed. Please file an issue on GitHub or try again."
private let unknownError = "Something went wrong. Please file an issue on GitHub or try again."

private func bodyIsUTF8(contentTypeHeader: String?, utf8ContentTypes: [String]) -> Bool {
    guard let contentType = contentTypeHeader?.split(separator: ";").first else {
        return false
    }
    return utf8ContentTypes.contains(String(contentType))
}

enum URLConstructionError: Error {
    case invalidBaseURL
    case invalidPathOrQueryParameters
}

enum URLRequestConstructionError: Error {
    case invalidBaseURL
    case invalidPathOrQueryParameters
    case invalidUTF8Body
    case invalidBase64Body
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
    
    var url: Result<URL, URLRequestConstructionError> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return .failure(.invalidBaseURL)
        }
        urlComponents.path = path
        
        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            return .failure(.invalidPathOrQueryParameters)
        }
        return .success(url)
    }
    
    var urlRequest: Result<URLRequest, URLRequestConstructionError> {
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
                        return .failure(.invalidUTF8Body)
                    }
                    urlRequest.httpBody = utf8Body
                } else {
                    guard let base64Body = Data(base64Encoded: body) else {
                        return .failure(.invalidBase64Body)
                    }
                    urlRequest.httpBody = base64Body
                }
            }
            return .success(urlRequest)
        }
    }
}

enum ResponseConstructionError: Error {
    case invalidHeaderParameters
    case invalidUTF8Body
}

struct Response: Encodable {
    let statusCode: Int
    let headerParameters: [String: String]
    @RequiredKey var body: String?
    
    init(statusCode: Int, headerParameters: [String: String], body: String?) {
        self.statusCode = statusCode
        self.headerParameters = headerParameters
        self.body = body
    }
    
    static func make(request: Request, data: Data, httpURLResponse: HTTPURLResponse) -> Result<Response, ResponseConstructionError> {
        guard let headerParameters = httpURLResponse.allHeaderFields as? [String: String] else {
            return .failure(.invalidHeaderParameters)
        }
        
        let bodyIsUTF8 = bodyIsUTF8(
            contentTypeHeader: httpURLResponse.value(forHTTPHeaderField: "Content-Type"),
            utf8ContentTypes: request.utf8ContentTypes
        )
        let body: String?
        if (bodyIsUTF8) {
            guard let utf8Body = String(data: data, encoding: .utf8) else {
                return .failure(.invalidUTF8Body)
            }
            body = utf8Body
        } else {
            body = data.base64EncodedString()
        }
        
        return .success(Response(
            statusCode: httpURLResponse.statusCode,
            headerParameters: headerParameters,
            body: body
        ))
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
                    return reject("@candlefinance.send.stringified_request_not_utf8", requestError, nil)
                }
                let request = try JSONDecoder().decode(Request.self, from: requestData)
                
                switch request.urlRequest {
                case .failure(let urlRequestConstructionError):
                    return reject("@candlefinance.send.request.\(urlRequestConstructionError)", requestError, nil)
                    
                case .success(let urlRequest):
                    let (data, urlResponse) = try await session.data(for: urlRequest)
                    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                        reject("@candlefinance.send.response.not_http_url_response", responseError, nil)
                        return
                    }
                    switch Response.make(
                        request: request,
                        data: data,
                        httpURLResponse: httpURLResponse
                    ) {
                    case .failure(let responseConstructionError):
                        return reject("@candlefinance.send.\(responseConstructionError)", requestError, nil)
                    case .success(let response):
                        let responseData = try JSONEncoder().encode(response)
                        guard let stringifiedResponse = String(data: responseData, encoding: .utf8) else {
                            return reject("@candlefinance.send.response_data_not_utf8", responseError, nil)
                        }
                        resolve(stringifiedResponse)
                    }
                }
                
            } catch let decodingError as DecodingError {
                reject("@candlefinance.send.stringified_request_invalid", requestError, decodingError)
                
            } catch let encodingError as EncodingError {
                reject("@candlefinance.send.response_invalid", responseError, encodingError)
                
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
                    reject("@candlefinance.send.request_invalid", requestError, urlError)
                    
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
                    reject("@candlefinance.send.no_response", serverError, urlError)
                    
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
                    reject("@candlefinance.send.response_data_invalid", responseError, urlError)
                    
                default:
                    // NOTE: The only other documented case is `unknown`, but code is not an enum so a default case is required regardless
                    reject("@candlefinance.send.unknown", unknownError, urlError)
                }
            } catch let error {
                reject("@candlefinance.send.unknown", unknownError, error)
            }
        }
    }
}
