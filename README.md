# Network

[![Swift 5.4](https://img.shields.io/badge/Swift-5.4-orange)](https://swift.org/blog/swift-5-4-released/) [![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-success)](https://swift.org/package-manager/) [![Swift](https://github.com/pkrll/network/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/pkrll/network/actions/workflows/swift.yml)

A simple network stack based on Dave DeLong's excellent exploration of the [HTTP stack in Swift](https://davedelong.com/blog/2020/06/27/http-in-swift-part-1/). 

* [Installation](#installation)
* [Usage](#usage)  
* [Documentation](#documentation)
  * [Request](#request)
    * [RequestOption](#requestoption)
      * [Environment](#environment)
      * [ThrottleOption](#throttleoption)
  * [Response](#response)
  * [HttpError](#httperror)
  * [Operators](#operators) 
    * [Creating Operators](#creating-operators)
      * [Custom Operators](#custom-operators)
  * [Task](#task)

## Installation

Network supports Swift Package Manager. Add ``.package(url: "https://github.com/pkrll/network.git", from: "0.1.0")`` to your ``Package.swift`` file to add it as a dependency. 

## Usage

The Network framework is comprised of so called operators. Each operator has a specific responsibility in the processing of a network request. The last operator in the chain must be a so-called *terminal* operator, meaning that it must in some manner actually decide what should happen with the request. Network offers only one terminal operator, the `TransportOperator`.

To make a network call, we must first build up the pipeline. This can be done by manually initializing and chaining each operator, or using the factory `OperationBuilder`. 

:warning:When using the `OperationBuilder` factory, always begin with appending the terminal operator. The last operator appended will be the one that begins the chain of events. The order of the operators matter, as they will examine, handle or modify the request before passing it along to the next operator in the chain.

The following code snippet shows an example on how to create a chain that calls a mock API endpoint.

```swift
import NetworkStack

let environment = Environment(host: "jsonplaceholder.typicode.com")

let builder = OperationBuilder()
let operation = builder
	.append(.transport(URLSession.shared))
	.append(.environment(environment))
	.build()  // This will return an Operator (with ApplyEnvironment as the first in the chain).

var request = Request(.get, headers: [:])
request.path = "posts"
// This can also be simplified as
// let request = Request.get("posts")

let task = operation.send(request) { result in
  switch result {
    case .failure(let error):
    	// error is an HttpError object.
    	handle(error: error)
    case .success(let response):
    	// response is a Response object.
    	handle(response: response)
  }
}
```

To send a `Request`, we must call the `send(_:completion:)` method on an operator. This will begin the processing, moving down the chain, passing the request along to the next operator in the chain. The `send(_:completion:)` method returns a `Task` structure. For more information, see the documentation for [Task](#task).

We must also pass in a completion handler that can return either an `HttpError`, or a`Response` object. For more information, see the documentation for [Response](#response) and [HttpError](#httpError).

## Documentation

### Request

Every call begins with a `Request`. This structure describes the request you wish to make and contains information on which HTTP method to use, the URL and any headers and data payload:

```swift
public struct Request {
    public let id: UUID
    public var method: Method { get }
    public var headers: [String: String] { get }
    public var body: Body
    public var scheme: String { get }
    public var url: URL? { get }
    public var host: String? { get set }
    public var path: String { get set }
    public init(_ method: Method = .get, headers: [String: String] = [:])
    public subscript<O>(option type: O.Type) -> O.Value where O: RequestOption { get set }
    public mutating func add(headers: [String: String])
    public mutating func add(queryItems: [URLQueryItem])
}
```

A `Request` can be constructed as follows:

```swift
var request = Request(.post) // .post => Method.post => Method(rawValue: "POST")
request.host = "some.domain.com"
request.path = "some/path"
request.add(headers: ["X-API-KEY": "someKey"])
reuest.add(queryItems: [URLQueryItem(name: "someQuery", value: "someValue")])
```

If you want to attach a body to your request, you can do so by setting the `body` property. This property is of type `Body`. There are three built-in `Body` types: `DataBody`, `JSONBody` and `EmptyBody`. It is also possible to create custom `Body` types, by conforming to the `Body` protocol.

Network also offers some convenience methods for the most common HTTP methods:

```swift
public extension Request {
    public static func delete(_ path: String, headers: [String: String] = [:]) -> Request
    public static func get(_ path: String) -> Request
    public static func patch(_ path: String) -> Request
    public static func post(_ path: String, headers: [String: String] = [:]) -> Request
    public static func put(_ path: String, headers: [String: String] = [:]) -> Request
}
```

#### RequestOption

Each `Request` can be customized to hold specific settings, a `RequestOption`. This allows for the operators, when examining the `Request`, to alter their behaviour individually.

Network offers two built-in options:

##### Environment

The `Environment` option can be used to specify the host and path of a request as well as the headers and query. There are several use-cases for this. For example:

* To more easily separate between the production and development environments, we can create two `Environment` options that each point to a different host.
* If the network calls requires some specific header, this can be specified on the `Environment`, which can then be applied to all requests before being performed.

:bulb: **Note:** The ``ApplyEnvironment`` operator is required to be a part of the chain.

If some requests requires a specific overridden environment, this can be achieved by modifying the `Request` object before sending it:

```swift
// This environment will be applied to all requests that have not overridden it.
let environment = Environment(host: "api.network.io", pathPrefix: "v1")
let builder = OperationBuilder()
let operation = builder
	.append(.transport(URLSession.shared))
	.append(.environment(environment))
	.build()

// This request will override the general environment set by the ApplyEnvironment operator.
var request = Request.get("some/endpoint")
request[option: Environment.self] = Environment(host: "api.network.io", pathPrefix: "v2")
```

##### ThrottleOption

The `Throttle` operator allows for limiting the number of requests that are sent. If, however, there are requests that must never be throttled, we can use `ThrottleOption` to make sure:

```swift
let environment = Environment(host: "api.network.io", pathPrefix: "v1")
let builder = OperationBuilder()
let operation = builder
	.append(.transport(URLSession.shared))
	.append(.environment(environment))
	.append(.throttle(1))
	.build()

// Making some requests that are throttled

// This request will never be throttled. It will fire as soon as possible, even if there
// are other requests that are suspended by the Throttle operator.
var request = Request.get("some/endpoint")
request[option: ThrottleOption.self] = .never
```

### Response

When the terminal operator has finished processing the request (for example, it has made a network call and gotten a repsonse, as in the case with `TransportOperator`), it will call the completion block passed to it with an argument of type `Result<Response, HttpError>` . The `Response` object contains information on the response:

```swift
public struct Response {
    public let request: Request
    public let data: Data?
    public var status: Status { get }
    public var headers: [AnyHashable : Any] { get }
    public var message: String { get }
}
```

### HttpError

On failures, we will receive an `HttpError`:

```swift
public struct HttpError : Error {
    public enum Code {
        case bodyExceedsMaximum
        case cannotConnect
        case cancelled
        case insecureConnection
        case invalidRequest
        case invalidResponse
        case isResetting
        case noConnection
        case unauthorized
        case unknown
    }
    
    public let code: Code
    public let request: Request
    public let response: Response?
    public let underlyingError: Error?
}
```

### Operators

The Network framework is comprised of so called operators. Each operator has a specific responsibility in the processing of a network request. 

You send a request on one or more operators, by chaining them together. The last operator in the chain must be a terminal operator, that handles the actual request.

Network has the following built-in operators:

| Operator            | Function                                                     |
| :------------------ | ------------------------------------------------------------ |
| `ApplyEnvironment`  | Applies an `Environment` to all requests passing through the pipeline. |
| `Autocancel`        | This operator cancels all in-flight tasks. Should be used in conjunction with the `ResetGuard` operator, as the next operator in the chain. |
| `ModifyRequest`     | This operator modifies all requests passing through the pipeline. |
| `ResetGuard`        | This operator prevents resetting an already resetting pipeline. This operator should preceed the operator `Autocancel`. |
| `Throttle`          | This operator allows for throttling requests.                |
| `TransportOperator` | This is a terminal operator, meaning it should be the last one in the chain. This operator performs the actual request. If injected with an `URLSession` object, it will call its `dataTask(with:completionHandler:)` method, starting the URL request. |

#### Creating Operators

There are two ways to create operators. You can either do it by explicitly initializing the operators you want to use. Make sure to set the `next` operator:

```swift
let autocancel = AutoCancel()
let applyEnvironment = ApplyEnvironment(environment: environment)
let transport = TransportOperator(transport: URLSession.shared)

autocancel.next = applyEnvironment
applyEnvironment.next = transport

autocancel.send(request) { result in
  // ...
}
```

Network also provides a factory:

```swift
let builder = OperationsBuilder()
let operation = builder
	.append(.transport(URLSession.shared))
	.append(.environment(environment))
  .append(.autocancel)
  .build()

operation.send(request) { result in
   // ...
}
```

The first operator appended to the builder, will serve as the terminal operator. The last operator will be the first one in the chain.

##### Custom Operators

It is also possible to create custom operators by subclassing the `Operator` class. Depending on your needs, you would want to override one or several of the super classes methods, as described below.

However, there are few reasons to subclass the `reset(on:completion:)` and `send(_:completion:)` methods. The base class `Operator` contains the logic needed in most cases.

If you would want to process the task in any particular way, you should override `load(_:)`, modify the task and send it to the next operator by calling `super.load(_:)`. If your operator should perform some specific action on reset, override the `reset(with:)` method, and call `super.reset(with:)` when finished.

```swift
open class Operator {
    /// The next operator in the chain.
    public var next: Operator? { get set }
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
    open func load(_ task: Task)
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
    open func reset(with group: DispatchGroup)
    /// Resets the entire chain. Any in-flight requests will be cancelled, if possible.
    ///
    /// Once the reset has been finished, the completion block will be invoked.
    ///
    /// - Parameter queue:      The dispatch queue used to call the completion block on.
    /// - Parameter completion: The completion block is invoked once the reset is done.
    open func reset(on queue: DispatchQueue = .main, completion: @escaping () -> Void)
    /// Prepares and sends the request.
    ///
    /// This method should be called on the first operator in the chain.
    ///
    /// - Parameter request:    The request to send.
    /// - Parameter completion: The completion block is invoked once the request has
    ///                         produced a result.
    open func send(_ request: Request, completion: @escaping (HttpResult) -> Void) -> Task
}
```

### Task

The ``send(_:completion)` method on an operator returns a `Task`. This object contains information on the request sent, and can be used to cancel the current request.

