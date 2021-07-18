import Foundation

public struct DataBody: Body {
    public var isEmpty: Bool { content.isEmpty }
    public let headers: [String: String]
    
    private let content: Data
    
    public init(_ content: Data, headers: [String: String] = [:]) {
        self.content = content
        self.headers = headers
    }
    
    public func encode() throws -> Data {
        content
    }
}
