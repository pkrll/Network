import Foundation

public final class ApplyEnvironment: Operator {
    
    private let environment: Environment
    
    public init(environment: Environment) {
        self.environment = environment
        super.init()
    }
    
    public override func load(_ task: Task) {
        var request = task.request
        let environment = request.environment ?? environment
        
        request.host = request.host.otherwise(environment.host)
        request.path = request.path.prefixingIfNeeded(with: environment.pathPrefix)

        request.add(queryItems: environment.query)
        request.add(headers: environment.headers)
        
        task.request = request
        
        super.load(task)
    }
}
