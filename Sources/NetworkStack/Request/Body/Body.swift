import Foundation

public protocol Body {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
    var headers: [String: String] { get }
    func encode() throws -> Data
}

public extension Body {
    var isEmpty: Bool { false }
    var isNotEmpty: Bool { !isEmpty }
    var headers: [String: String] { [:] }
}
