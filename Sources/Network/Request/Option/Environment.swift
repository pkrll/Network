import Foundation
import Shared

public struct Environment: RequestOption {
    
    public static let defaultOption: Environment? = nil
    
    public let host: String
    public let pathPrefix: String
    public let headers: [String: String]
    public let query: [URLQueryItem]
    
    public init(host: String,
                pathPrefix: String = "",
                headers: [String: String] = [:],
                query: [URLQueryItem] = []) {
        self.host = host
        self.pathPrefix = pathPrefix.prefixingIfNeeded(with: "/")
        self.headers = headers
        self.query = query
    }
}
