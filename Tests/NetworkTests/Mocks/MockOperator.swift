import Foundation
@testable import Network

final class MockOperator: Operator {
    
    private(set) var hasResetted: Bool = false
    
    init() {
        super.init()
    }
    
    override func reset(with group: DispatchGroup) {
        hasResetted = true
        next?.reset(with: group)
    }
}
