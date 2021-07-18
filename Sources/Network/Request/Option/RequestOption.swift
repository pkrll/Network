import Foundation

public protocol RequestOption {
    associatedtype Value
    static var defaultOption: Value { get }
}
