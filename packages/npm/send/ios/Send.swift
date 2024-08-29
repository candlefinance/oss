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
    
    case decodingError
    case encodingError
    
    case unknown
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
            urlRequest.httpMethod = method
            
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
    
    func send(request: Request) throws -> NitroModules.Promise<Response> {
        return Promise.async { [weak self] in
            if let self {
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
            } else {
                throw SendError.unknown
            }
        }
    }
    
}
