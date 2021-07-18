import Foundation

public final class ModifyRequest: Operator {
    
    private let modifier: (Request) -> Request
    
    public init(modifier: @escaping (Request) -> Request, next: Operator? = nil) {
        self.modifier = modifier
        super.init(next: next)
    }
    
    public override func load(_ task: Task) {
        task.request = modifier(task.request)
        super.load(task)
    }
}
