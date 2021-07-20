import Foundation

public extension Request {
    
    static func delete(_ path: String, headers: [String: String] = [:]) -> Self {
        var request = Request(.delete, headers: headers)
        request.path = path
        
        return request
    }
    
    static func get(_ path: String) -> Self {
        var request = Request(.get, headers: [:])
        request.path = path
        
        return request
    }
    
    static func patch(_ path: String) -> Self {
        var request = Request(.patch, headers: [:])
        request.path = path
        
        return request
    }
    
    static func post(_ path: String, headers: [String: String] = [:]) -> Self {
        var request = Request(.post, headers: headers)
        request.path = path
        
        return request
    }
    
    static func put(_ path: String, headers: [String: String] = [:]) -> Self {
        var request = Request(.put, headers: headers)
        request.path = path
        
        return request
    }
}
