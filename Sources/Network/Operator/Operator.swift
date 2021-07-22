import Foundation

open class Operator {
    /// The next operator in the chain.
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
    /// Loads the given Task.
    ///
    /// We usually do not want to call this method from outside. Instead, use the
    /// `send(_:completion:)` method. Internally, that method should call `load(_:)`,
    /// once it has finished processing the request.
    ///
    /// - Note: Any custom classes that serve as the terminal operator must implement this
    ///         method. Otherwise, an error is returned.
    ///
    /// - Parameter task: The task to process.
    open func load(_ task: Task) {
        if let next = next {
            next.load(task)
        } else {
            task.fail(.cannotConnect)
        }
    }
    /// Invoked when a reset has been requested. This method should reset any internal state,
    /// if possible.
    ///
    /// Once the reset has been made, the operator must call the next operator in the chain,
    /// with the same dispatch group object.
    ///
    /// - Note: This method should not be called from the outside. This is an internal method
    ///         used within the operator chain. To begin a reset, call `reset(on:completion:)`.
    ///
    /// - Parameter group: Used to synchronize the reset.
    open func reset(with group: DispatchGroup) {
        next?.reset(with: group)
    }
    /// Resets the entire chain. Any in-flight requests will be cancelled, if possible.
    ///
    /// Once the reset has been finished, the completion block will be invoked.
    ///
    /// - Parameter queue:      The dispatch queue used to call the completion block on.
    /// - Parameter completion: The completion block is invoked once the reset is done.
    open func reset(on queue: DispatchQueue = .main, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        self.reset(with: group)
        
        group.notify(queue: queue, execute: completion)
    }
    /// Prepares and sends the request.
    ///
    /// This method should be called on the first operator in the chain.
    ///
    /// - Parameter request:    The request to send.
    /// - Parameter completion: The completion block is invoked once the request has
    ///                         produced a result.
    @discardableResult
    open func send(_ request: Request, completion: @escaping (HttpResult) -> Void) -> Task {
        let task = Task(request: request, completion: completion)
        load(task)
        
        return task
    }
}
