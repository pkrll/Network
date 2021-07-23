import Foundation

public extension Request {
    var environment: Environment? {
        get { self[option: Environment.self] }
        set { self[option: Environment.self] = newValue }
    }
}
