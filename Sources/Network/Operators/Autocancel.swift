import Foundation

public final class Autocancel: Operator {
    
    private let queue: DispatchQueue = .init(label: "com.ardalansamimi.network.autocancel")
    private var tasks: [UUID: Task] = [:]
    
    public override func load(_ task: Task) {
        queue.sync {
            let id = task.id
            tasks[id] = task
            
            task.addCompletion { [weak self] _ in
                guard let self = self else { return }
                self.queue.sync {
                    self.tasks[id] = nil
                }
            }
        }
        
        super.load(task)
    }
    
    public override func reset(with group: DispatchGroup) {
        group.enter()
        queue.async {
            let tasks = self.tasks
            self.tasks = [:]
            
            DispatchQueue.global(qos: .userInitiated).async {
                for task in tasks.values {
                    group.enter()
                    
                    task.addCompletion { _ in
                        group.leave()
                    }
                    
                    task.cancel()
                }
                
                group.leave()
            }
        }
        
        next?.reset(with: group)
    }
}
