import Foundation

public final class Logging: Operator {
    
    public override init(next: Operator? = nil) {
        super.init(next: next)
    }
    
    public override func load(_ task: Task) {
        print("Loading \(task.request)")
        task.addCompletion { result in
            print("Got result: \(result)")
        }
        
        super.load(task)
    }
}
