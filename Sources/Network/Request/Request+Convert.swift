import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    
    func convert() throws -> URLRequest {
        guard let url = url else {
            throw HttpError(code: .invalidRequest, request: self, response: nil, underlyingError: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers.forEach { (header, value) in
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        if body.isNotEmpty {
            body.headers.forEach { (header, value) in
                request.addValue(value, forHTTPHeaderField: header)
            }
            
            do {
                request.httpBody = try body.encode()
            } catch {
                throw HttpError(code: .invalidRequest, request: self, response: nil, underlyingError: error)
            }
        }

        return request
    }
}
