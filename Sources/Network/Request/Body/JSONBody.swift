import Foundation

public struct JSONBody: Body {
    public let isEmpty: Bool = false
    public var headers = [
        "Content-Type": "application/json; charset=utf-8"
    ]
    
    private let content: () throws -> Data
    
    public init<T: Encodable>(_ value: T, encoder: Encoder = JSONEncoder()) {
        self.content = {
            try encoder.encode(value)
        }
    }
    
    public func encode() throws -> Data {
        try content()
    }
}
