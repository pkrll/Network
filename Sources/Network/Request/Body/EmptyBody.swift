import Foundation

public struct EmptyBody: Body {
    public let isEmpty: Bool = true
    public init() {}
    public func encode() throws -> Data { Data() }
}
