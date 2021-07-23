import Foundation
@testable import NetworkStack

final class MockOperator: Operator {
    
    private(set) var hasResetted: Bool = false
    private(set) var hasCancelled: Bool = false
    private let accessQueue: DispatchQueue = .init(label: "com.ardalansamimi.network.MockOperator")
    
    override init(next: Operator? = nil) {
        super.init(next: next)
    }
    
    override func reset(with group: DispatchGroup) {
        accessQueue.async(flags: .barrier) {
            self.hasResetted = true
        }

        next?.reset(with: group)
    }
    
    override func load(_ task: Task) {
        task.addCancellation {
            self.accessQueue.async(flags: .barrier) {
                self.hasCancelled = true
            }
        }
        
        super.load(task)
    }
}
