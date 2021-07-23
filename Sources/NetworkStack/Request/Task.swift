import Foundation

public final class Task {
    
    public var id: UUID { request.id }
    public var request: Request
    
    private let accessQueue: DispatchQueue = .init(label: "com.ardalansamimi.network.task", attributes: .concurrent)
    private var completionHandlers: [(HttpResult) -> Void] = []
    private var cancellationHandlers: [() -> Void] = []
    
    private var isCancelled: Bool = false
    private var hasFinished: Bool = false
    
    private var hasCancelledOrFinished: Bool {
        var isCancelled = false
        var hasFinished = false
        
        accessQueue.async {
            isCancelled = self.isCancelled
            hasFinished = self.hasFinished
        }
        
        return isCancelled || hasFinished
    }
    
    public init(request: Request, completion: @escaping (HttpResult) -> Void) {
        self.request = request
        self.completionHandlers = [completion]
    }
    
    public func addCompletion(handler: @escaping (HttpResult) -> Void) {
        accessQueue.async(flags: .barrier) {
            self.completionHandlers.append(handler)
        }
    }
    
    public func addCancellation(handler: @escaping () -> Void) {
        if hasCancelledOrFinished {
            return
        }

        accessQueue.async(flags: .barrier) {
            self.cancellationHandlers.append(handler)
        }
    }
    
    public func cancel() {
        if hasCancelledOrFinished {
            return
        }
        
        accessQueue.async(flags: .barrier) {
            self.isCancelled = true
        }
        
        var handlers: [() -> Void] = []
        accessQueue.sync {
            handlers = self.cancellationHandlers
        }
        
        handlers.reversed().forEach { cancel in
            cancel()
        }
    }
    
    public func complete(with result: HttpResult) {
        if hasFinished {
            return
        }
        
        hasFinished = true
        completionHandlers.forEach { handler in
            handler(result)
        }
    }
    
    public func fail(_ code: HttpError.Code) {
        let error = HttpError(code: code, request: request)
        complete(with: .failure(error))
    }
}
