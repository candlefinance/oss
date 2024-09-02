import Foundation
import NitroModules

private func bodyIsUTF8(contentTypeHeader: String?, utf8ContentTypes: [String]) -> Bool {
    guard let contentType = contentTypeHeader?.split(separator: ";").first else {
        return false
    }
    return utf8ContentTypes.contains(String(contentType))
}

extension SendError: Error {}

extension SendRequest {
    var url: Result<URL, SendError> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return .failure(SendError(code: .invalidRequestBaseUrl, message: "Your base URL is not valid."))
        }
        urlComponents.path = path
        
        if !query.parameters.isEmpty {
            urlComponents.queryItems = query.parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            return .failure(SendError(code: .invalidRequestPathOrQueryParameters, message: "Your path or query parameters is not valid."))
        }
        return .success(url)
    }
    
    var urlRequest: Result<URLRequest, SendError> {
        return url.flatMap { url in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.stringValue
            
            for (key, value) in header.parameters {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            if let body {
                let contentTypeHeader = header.parameters.first(where: { $0.key.caseInsensitiveCompare("Content-Type") == .orderedSame })?.value
                if bodyIsUTF8(contentTypeHeader: contentTypeHeader, utf8ContentTypes: utf8ContentTypes) {
                    guard let utf8Body = body.data(using: .utf8) else {
                        return .failure(SendError(code: .nonUtf8RequestBody, message: "Your request headers specify a Content-Type included in `utf8ContentTypes`, but your request body is not a UTF8-encoded string."))
                    }
                    urlRequest.httpBody = utf8Body
                } else {
                    guard let base64Body = Data(base64Encoded: body) else {
                        return .failure(SendError(code: .nonBase64RequestBody, message: "Your request headers specify a Content-Type NOT included in `utf8ContentTypes`, but your request body is not a base64-encoded string."))
                    }
                    urlRequest.httpBody = base64Body
                }
            }
            return .success(urlRequest)
        }
    }
}

extension SendResponse {
    init(request: SendRequest, data: Data, httpURLResponse: HTTPURLResponse) throws {
        guard let headerParameters = httpURLResponse.allHeaderFields as? [String: String] else {
            throw SendError(code: .invalidResponseHeaderParameters, message: "The response headers were not valid.")
        }
        let statusCode = Double(httpURLResponse.statusCode)
        let header = SendParameters(parameters: headerParameters)
        if (data.isEmpty) {
            self.init(statusCode: statusCode, header: header, body: nil)
        } else {
            let bodyIsUTF8 = bodyIsUTF8(
                contentTypeHeader: httpURLResponse.value(forHTTPHeaderField: "Content-Type"),
                utf8ContentTypes: request.utf8ContentTypes
            )
            if (bodyIsUTF8) {
                guard let utf8Body = String(data: data, encoding: .utf8) else {
                    throw SendError(code: .nonUtf8ResponseBody, message: "The response headers specify a Content-Type included in `utf8ContentTypes`, but the response body was not UTF8-encoded.")
                }
                self.init(statusCode: statusCode, header: header, body: utf8Body)
            } else {
                self.init(
                    statusCode: statusCode,
                    header: header,
                    body: data.base64EncodedString()
                )
            }
        }
    }
}

final class IgnoreRedirectsDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        return nil
    }
}

final class Send: HybridSendSpec {
    
    var hybridContext = margelo.nitro.HybridContext()
    
    var memorySize: Int {
        return getSizeOf(self)
    }
    
    lazy var session = URLSession(
        configuration: .default,
        delegate: IgnoreRedirectsDelegate(),
        delegateQueue: nil
    )
    
    func send(request: SendRequest) throws -> Promise<SendResult> {
        return Promise.async { [weak self] in
            guard let self else {
                return .init(response: nil, error: nil)
            }
            do {
                let urlRequest = try request.urlRequest.get()
                let (data, urlResponse) = try await self.session.data(for: urlRequest)
                guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                    let sendError = SendError(code: .responseInvalid, message: "Your request received a response, but it couldn't be processed. Please verify the configuration of your server.")
                    return SendResult(response: nil, error: sendError)
                }
                let response = try SendResponse(
                    request: request,
                    data: data,
                    httpURLResponse: httpURLResponse
                )
                return SendResult(response: response, error: nil)
            } catch let sendError as SendError {
                return SendResult(response: nil, error: sendError)
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
                    let sendError = SendError(code: .requestInvalid, message: urlError.localizedDescription)
                    return SendResult(response: nil, error: sendError)
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
                    let sendError = SendError(code: .noResponse, message: urlError.localizedDescription)
                    return SendResult(response: nil, error: sendError)
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
                    let sendError = SendError(code: .responseInvalid, message: urlError.localizedDescription)
                    return SendResult(response: nil, error: sendError)
                default:
                    // NOTE: The only other documented case is `unknown`, but code is not an enum so a default case is required regardless
                    let sendError = SendError(code: .unexpected, message: urlError.localizedDescription)
                    return SendResult(response: nil, error: sendError)
                }
            } catch let error {
                let sendError = SendError(code: .unexpected, message: error.localizedDescription)
                return SendResult(response: nil, error: sendError)
            }
        }
    }
}
