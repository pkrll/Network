import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias HttpResult = Result<Response, HttpError>

public extension HttpResult {
    var request: Request {
        switch self {
        case .failure(let error):
            return error.request
        case .success(let response):
            return response.request
        }
    }
    
    var response: Response? {
        switch self {
        case .failure(let error):
            return error.response
        case .success(let response):
            return response
        }
    }
    
    init(request: Request, data: Data?, response: URLResponse?, error: Error?) {
        do {
            let response = try Response(for: request, with: response, data: data, error: error)
            self = .success(response)
        } catch let error as HttpError {
            self = .failure(error)
        } catch {
            self = .failure(.init(code: .invalidResponse, request: request, underlyingError: error))
        }
    }
}
