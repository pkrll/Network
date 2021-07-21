import Foundation

/// Creates a single or a chain of ``Operator`` objects.
///
/// - Note: The terminal operator should be added first in the building process,
///         as the objects are prepended to the chain when using the convenience
///         methods or the ``create(operator:)`` method.
public class OperationBuilder {
    
    public enum Operation {
        case autocancel
        case environment(Environment)
        case modifyRequest(_ modifier: (Request) -> Request)
        case logging
        case transport(Transport)
        case resetGuard
        case throttle(UInt)
    }
    
    private var next: Operator?
    
    public init() {}
    
    public func append(_ operator: Operation) -> Self {
        switch `operator` {
        case .autocancel:
            return autocancel()
        case .environment(let environment):
            return applyEnvironment(environment: environment)
        case .logging:
            return logging()
        case .modifyRequest(let modifier):
            return modifyRequest(modifier)
        case .resetGuard:
            return resetGuard()
        case .transport(let transport):
            return transportOperator(transport: transport)
        case .throttle(let count):
            return throttle(count: count)
        }
    }
    /// Prepends the specified ``Operation`` object to the chain of ``Operation``s.
    ///
    /// - Parameter operation: A closure that must evaluate to a ``Operation``.
    public func create(operation: () -> Operator) -> Self {
        let operation = operation()
        
        operation.next = next
        next = operation
        
        return self
    }
    /// Returns the chained operation.
    public func build() -> Operator {
        next!
    }
    
    private func applyEnvironment(environment: Environment) -> Self {
        create { ApplyEnvironment(environment: environment) }
    }
    
    private func autocancel() -> Self {
        create { Autocancel() }
    }
    
    private func logging() -> Self {
        create { Logging() }
    }
    
    private func modifyRequest(_ modifier: @escaping (Request) -> Request) -> Self {
        create { ModifyRequest(modifier: modifier) }
    }
    
    private func resetGuard() -> Self {
        create { ResetGuard() }
    }
    
    private func transportOperator(transport: Transport) -> Self {
        create { TransportOperator(transport: transport) }
    }
    
    private func throttle(count: UInt) -> Self {
        create { Throttle(count: count) }
    }
}
