import Foundation

extension Optional where Wrapped == String {
    func otherwise(_ fallback: @autoclosure () -> String) -> String {
        guard let self = self else {
            return fallback()
        }
        
        return self
    }
}
