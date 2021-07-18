import Foundation

public final class ResetGuard: Operator {
    
    private var isResetting: Bool = false
    private let accessQueue: DispatchQueue = .init(label: "com.ardalansamimi.network.resetGuard")
    
    public override init(next: Operator? = nil) {
        super.init(next: next)
    }
    
    public override func reset(with group: DispatchGroup) {
        var isResetting: Bool = false

        accessQueue.sync {
            isResetting = self.isResetting
        }
        
        guard !isResetting, let next = next else {
            return
        }
        
        group.enter()
        
        accessQueue.async(flags: .barrier) {
            self.isResetting = true
        }

        next.reset { [weak self] in
            self?.accessQueue.async(flags: .barrier) {
                self?.isResetting = false
            }
            
            group.leave()
        }
    }
    
    public override func load(_ task: Task) {
        if isResetting {
            task.fail(.isResetting)
        } else {
            super.load(task)
        }
    }
}
