import Foundation

public struct Method: Hashable {
    public static let delete = Self(rawValue: "DELETE")
    public static let get = Self(rawValue: "GET")
    public static let post = Self(rawValue: "POST")
    public static let put = Self(rawValue: "PUT")
    
    public let rawValue: String
}
