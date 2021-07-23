import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension String {
    static func localizedString(forStatusCode statusCode: Int) -> String {
        HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
    
    func prefixingIfNeeded(with prefix: String) -> Self {
        guard !hasPrefix(prefix) else {
            return self
        }
        
        return "\(prefix)\(self)"
    }
}
