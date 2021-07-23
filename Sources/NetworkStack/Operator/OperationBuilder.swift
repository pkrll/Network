import Foundation

/// Creates a single or a chain of ``Operator`` objects.
///
/// - Note: The terminal operator should be added first in the building process,
///         as the objects are prepended to the chain when using the convenience
///         methods or the ``create(operator:)`` method.
open class OperationBuilder {
    
    public enum Operation {
        case autocancel
        case environment(Environment)
        case modifyRequest(_ modifier: (Request) -> Request)
        case logging
        case transport(Transport)
        case resetGuard
        case throttle(UInt)
    }
    
    private var previous: Operator?
    
    public init() {}
    
    open func append(_ operator: Operation) -> Self {
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
    /// Appends the specified ``Operation`` object to the chain of ``Operation``s.
    ///
    /// - Parameter operation: A closure that must evaluate to a ``Operation``.
    open func append(operator: Operator) -> Self {
        `operator`.next = previous
        previous = `operator`
        
        return self
    }
    /// Returns the chained operation.
    open func build() -> Operator {
        previous!
    }
    
    private func applyEnvironment(environment: Environment) -> Self {
        append(operator: ApplyEnvironment(environment: environment))
    }
    
    private func autocancel() -> Self {
        append(operator: Autocancel())
    }
    
    private func logging() -> Self {
        append(operator: Logging())
    }
    
    private func modifyRequest(_ modifier: @escaping (Request) -> Request) -> Self {
        append(operator: ModifyRequest(modifier: modifier))
    }
    
    private func resetGuard() -> Self {
        append(operator: ResetGuard())
    }
    
    private func transportOperator(transport: Transport) -> Self {
        append(operator: TransportOperator(transport: transport))
    }
    
    private func throttle(count: UInt) -> Self {
        append(operator: Throttle(count: count))
    }
}
