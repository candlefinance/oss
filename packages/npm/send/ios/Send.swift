import Foundation
import NitroModules

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
}

final class IgnoreRedirectsDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        return nil
    }
}

extension Request {
    var url: Result<URL, SendError> {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return .failure(.invalidRequestBaseURL)
        }
        urlComponents.path = path
        
        if !query.parameters.isEmpty {
            urlComponents.queryItems = query.parameters.map { key, value in
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
            urlRequest.httpMethod = String(describing: method)
            
            for (key, value) in header.parameters {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            if let body {
                let contentTypeHeader = header.parameters.first(where: { $0.key.caseInsensitiveCompare("Content-Type") == .orderedSame })?.value
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

extension Response {
    init(request: Request, data: Data, httpURLResponse: HTTPURLResponse) throws {
        guard let headerParameters = httpURLResponse.allHeaderFields as? [String: String] else {
            throw SendError.invalidResponseHeaderParameters
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
                    throw SendError.nonUTF8ResponseBody
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
    
    func send(request: Request) async throws -> Response {
        do {
            let urlRequest = try request.urlRequest.get()
            let (data, urlResponse) = try await session.data(for: urlRequest)
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                throw SendError.nonUTF8ResponseBody
            }
            let response = try Response(
                request: request,
                data: data,
                httpURLResponse: httpURLResponse
            )
            return response
        } catch let sendError as SendError {
            switch (sendError) {
            case .nonBase64RequestBody,
                    .invalidRequestBaseURL,
                    .nonUTF8RequestBody,
                    .invalidRequestPathOrQueryParameters:
                throw SendError.nonUTF8RequestBody
                
            case .nonUTF8ResponseBody,
                    .invalidResponseHeaderParameters:
                throw SendError.nonUTF8ResponseBody
            }
            
        } catch let _ as DecodingError {
            throw SendError.nonUTF8ResponseBody
            
        } catch let _ as EncodingError {
            throw SendError.nonUTF8ResponseBody
            
        } catch let urlError as URLError {
            print(urlError)
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
                throw SendError.nonUTF8ResponseBody
                
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
                throw SendError.nonUTF8ResponseBody
                
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
                throw SendError.nonUTF8ResponseBody
                
            default:
                // NOTE: The only other documented case is `unknown`, but code is not an enum so a default case is required regardless
                throw SendError.nonUTF8ResponseBody
            }
        } catch _ {
            throw SendError.nonUTF8ResponseBody
        }
    }
    
    func send(request: Request) throws -> NitroModules.Promise<Response> {
        return Promise.async { [weak self] in
            if let self {
                return try await self.send(request: request)
            } else {
                throw SendError.nonUTF8ResponseBody
            }
        }
    }
    
}
