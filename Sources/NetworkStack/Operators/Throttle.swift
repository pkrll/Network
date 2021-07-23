import Foundation

public final class Throttle: Operator {
    private let accessQueue: DispatchQueue = .init(label: "com.ardalansamimi.network.throttle")
    private var maximumNumberOfTasks: UInt
    private var runningTasks: [UUID: Task] = [:]
    private var pendingTasks: [Task] = []
    
    private var canStartTask: Bool {
        var runningTasks: UInt = 0
        var maximumTasks: UInt = 0
        
        accessQueue.sync {
            runningTasks = self.runningTasks.count.uint
            maximumTasks = self.maximumNumberOfTasks
        }
        
        return runningTasks < maximumTasks
    }
    
    private var canStartNextTask: Bool {
        var runningTasks: UInt = 0
        var maximumTasks: UInt = 0
        var hasPendingTasks = false
        
        accessQueue.sync {
            runningTasks = self.runningTasks.count.uint
            maximumTasks = self.maximumNumberOfTasks
            hasPendingTasks = !pendingTasks.isEmpty
        }
        
        return hasPendingTasks && runningTasks < maximumTasks
    }
    
    public init(count: UInt = .max) {
        maximumNumberOfTasks = count
        super.init(next: nil)
    }
    
    public override func load(_ task: Task) {
        guard case .always = task.request.throttle else {
            super.load(task)
            return
        }
        
        if canStartTask {
            start(task: task)
        } else {
            pause(task: task)
        }
    }
    
    public override func reset(with group: DispatchGroup) {
        group.enter()
        accessQueue.async {
            let runningTasks = self.runningTasks
            let pendingTasks = self.pendingTasks
            
            self.runningTasks = [:]
            self.pendingTasks = []
            
            DispatchQueue.global(qos: .userInitiated).async {
                for task in runningTasks.values {
                    group.enter()
                    
                    task.addCompletion { _ in
                        group.leave()
                    }
                    
                    task.cancel()
                }
                
                for task in pendingTasks {
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
    
    private func start(task: Task) {
        let id = task.id
        
        accessQueue.async(flags: .barrier) {
            self.runningTasks[id] = task
        }
        
        task.addCompletion { [weak self] _ in
            guard let self = self else { return }
            self.accessQueue.async(flags: .barrier) {
                self.runningTasks[id] = nil
            }
            
            self.startNextTaskIfPossbile()
        }
        
        super.load(task)
    }
    
    private func startNextTaskIfPossbile() {
        while canStartNextTask {
            self.removingFirstTask { task in
                guard let task = task else { return }
                
                start(task: task)
            }
        }
    }
    
    private func pause(task: Task) {
        self.accessQueue.sync(flags: .barrier) {
            self.pendingTasks.append(task)
        }
        
        task.addCancellation { [weak task] in
            guard let task = task else { return }
            let error = HttpError(code: .cancelled, request: task.request)
            task.complete(with: .failure(error))
        }
    }
    
    private func removingFirstTask(execute: (Task?) -> Void) {
        var task: Task?
        self.accessQueue.sync {
            task = self.pendingTasks.first
        }
        
        if task != nil {
            self.accessQueue.async(flags: .barrier) {
                self.pendingTasks.removeFirst()
            }
        }
        
        execute(task)
    }
}
