import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Response {
    public let request: Request
    public let data: Data?
    private let response: HTTPURLResponse
    
    public var status: Status { Status(response.statusCode) }
    public var headers: [AnyHashable: Any] { response.allHeaderFields }
    public var message: String { .localizedString(forStatusCode: response.statusCode) }
}

extension Response {
    init(for request: Request, with response: URLResponse?, data: Data?, error: Error?) throws {
        if let error = error as? URLError {
            let response = Response(request: request, response: response, data: data)
            throw HttpError(code: error.httpErrorCode, request: request, response: response, underlyingError: error)
        }
        
        if let error = error {
            let response = Response(request: request, response: response, data: data)
            throw HttpError(code: .unknown, request: request, response: response, underlyingError: error)
        }
        
        guard let response = response as? HTTPURLResponse else {
            throw HttpError(code: .invalidResponse, request: request, response: nil, underlyingError: error)
        }
        
        self.request = request
        self.data = data
        self.response = response
    }
    
    init?(request: Request, response: URLResponse?, data: Data?) {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        
        self.request = request
        self.data = data
        self.response = response
    }
}
