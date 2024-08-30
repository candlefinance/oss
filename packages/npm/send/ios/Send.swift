import Foundation
import NitroModules

private func bodyIsUTF8(contentTypeHeader: String?, utf8ContentTypes: [String]) -> Bool {
    guard let contentType = contentTypeHeader?.split(separator: ";").first else {
        return false
    }
    return utf8ContentTypes.contains(String(contentType))
}

extension SendError: Error {}

extension Request {
    var url: Result<URL, SendError> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return .failure(SendError(code: .invalid_request_base_url, message: "Your base URL is not valid."))
        }
        urlComponents.path = path
        
        if !query.parameters.isEmpty {
            urlComponents.queryItems = query.parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            return .failure(SendError(code: .invalid_request_path_or_query_parameters, message: "Your path or query parameters is not valid."))
        }
        return .success(url)
    }
    
    var urlRequest: Result<URLRequest, SendError> {
        return url.flatMap { url in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            
            for (key, value) in header.parameters {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            if let body {
                let contentTypeHeader = header.parameters.first(where: { $0.key.caseInsensitiveCompare("Content-Type") == .orderedSame })?.value
                if bodyIsUTF8(contentTypeHeader: contentTypeHeader, utf8ContentTypes: utf8ContentTypes) {
                    guard let utf8Body = body.data(using: .utf8) else {
                        return .failure(SendError(code: .non_utf8_request_body, message: "Your request headers specify a Content-Type included in `utf8ContentTypes`, but your request body is not a UTF8-encoded string."))
                    }
                    urlRequest.httpBody = utf8Body
                } else {
                    guard let base64Body = Data(base64Encoded: body) else {
                        return .failure(SendError(code: .non_base64_request_body, message: "Your request headers specify a Content-Type NOT included in `utf8ContentTypes`, but your request body is not a base64-encoded string."))
                    }
                    urlRequest.httpBody = base64Body
                }
            }
            return .success(urlRequest)
        }
    }
}

extension Response {
    init(request: Request, data: Data, httpURLResponse: HTTPURLResponse) throws {
        guard let headerParameters = httpURLResponse.allHeaderFields as? [String: String] else {
            throw SendError(code: .invalid_response_header_parameters, message: "The response headers were not valid.")
        }
        let body: String?
        if (data.isEmpty) {
            body = nil
        } else {
            let bodyIsUTF8 = bodyIsUTF8(
                contentTypeHeader: httpURLResponse.value(forHTTPHeaderField: "Content-Type"),
                utf8ContentTypes: request.utf8ContentTypes
            )
            if (bodyIsUTF8) {
                guard let utf8Body = String(data: data, encoding: .utf8) else {
                    throw SendError(code: .non_utf8_response_body, message: "The response headers specify a Content-Type included in `utf8ContentTypes`, but the response body was not UTF8-encoded.")
                }
                body = utf8Body
            } else {
                body = data.base64EncodedString()
            }
        }
        self.init(
            statusCode: Double(httpURLResponse.statusCode),
            header: Parameters(parameters: headerParameters),
            body: body
        )
    }
}

final class IgnoreRedirectsDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        return nil
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    lazy var session: URLSession = {
        return URLSession(
            configuration: .default,
            delegate: IgnoreRedirectsDelegate(),
            delegateQueue: nil
        )
    }()
    
    private init() {}
}

final class Send: HybridSendSpec {
    
    var hybridContext = margelo.nitro.HybridContext()
    
    var memorySize: Int {
        return getSizeOf(self)
    }
    
    lazy var session = NetworkManager.shared.session
    
    func send(request: Request) -> NitroModules.Promise<SendResult> {
        return Promise.async { [weak self] in
            if let self {
                do {
                    let urlRequest = try request.urlRequest.get()
                    let (data, urlResponse) = try await session.data(for: urlRequest)
                    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                        let sendError = SendError(code: .response_invalid, message: "The response headers specify a Content-Type included in `utf8ContentTypes`, but the response body was not UTF8-encoded.")
                        return SendResult(response: nil, error: sendError)
                    }
                    let response = try Response(
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
                        let sendError = SendError(code: .request_invalid, message: urlError.localizedDescription)
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
                        let sendError = SendError(code: .no_response, message: urlError.localizedDescription)
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
                        let sendError = SendError(code: .response_invalid, message: urlError.localizedDescription)
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
            } else {
                let sendError = SendError(code: .unexpected, message: "Reference to self is nil.")
                return SendResult(response: nil, error: sendError)
            }
        }
    }
}
