import Foundation

open class Operator {
    
    public var next: Operator? {
        willSet {
            guard next == nil else {
                fatalError("Next transporter may only be set once.")
            }
        }
    }
    
    init(next: Operator? = nil) {
        self.next = next
    }
    
    open func load(_ task: Task) {
        if let next = next {
            next.load(task)
        } else {
            task.fail(.cannotConnect)
        }
    }
    
    open func reset(with group: DispatchGroup) {
        next?.reset(with: group)
    }
    
    open func reset(on queue: DispatchQueue = .main, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        self.reset(with: group)
        
        group.notify(queue: queue, execute: completion)
    }
    
    @discardableResult
    open func send(_ request: Request, completion: @escaping (HttpResult) -> Void) -> Task {
        let task = Task(request: request, completion: completion)
        load(task)
        
        return task
    }
}
