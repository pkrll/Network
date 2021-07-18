import Foundation

public struct HttpError: Error {
    public let code: Code
    public let request: Request
    public let response: Response?
    public let underlyingError: Error?
    
    public enum Code {
        case bodyExceedsMaximum
        case cannotConnect
        case cancelled
        case insecureConnection
        case invalidRequest
        case invalidResponse
        case isResetting
        case noConnection
        case unauthorized
        case unknown
    }
    
    init(code: Code, request: Request, response: Response? = nil, underlyingError: Error? = nil) {
        self.code = code
        self.request = request
        self.response = response
        self.underlyingError = underlyingError
    }
}

extension HttpError {
    static func from(_ error: Error?, code: Code, request: Request, response: Response? = nil) -> Self {
        Self(code: code, request: request, response: response, underlyingError: error)
    }
}
