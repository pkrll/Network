import Foundation

public protocol BodyEncoding {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

extension JSONEncoder: BodyEncoding {}
