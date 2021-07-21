# Network

![Swift 5.4](https://img.shields.io/badge/Swift-5.4-orange) ![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-success)

A simple network stack based on Dave DeLong's excellent exploration of the [HTTP stack in Swift](https://davedelong.com/blog/2020/06/27/http-in-swift-part-1/). 

* [Installation](#installation)
* [Usage](#usage)  
  * [Request](#request)
    * [RequestOption](#requestoption)
      * [Environment](#environment)
      * [ThrottleOption](#throttleoption)
  * [Response](#response)
  * [HttpError](#httperror)
  * [Operators](#operators) 

## Installation

Network supports Swift Package Manager. Add ``.package(url: "https://github.com/pkrll/network.git", from: "1.0.0")`` to your ``Package.swift`` file to add it as a dependency. 

## Usage

The Network framework is comprised of so called operators. Each operator has a specific responsibility in the processing of a network request. The last operator in the chain must be a so-called *terminal* operator, meaning that it must in some manner actually decide what should happen with the request. Network offers only one terminal operator, the `TransportOperator`.

To make a network call, we must first build up the pipeline. This can be done by manually initializing and chaining each operator, or using the factory `OperationBuilder`. 

:warning:When using the `OperationBuilder` factory, always begin with appending the terminal operator. The last operator appended will be the one that begins the chain of events. The order of the operators matter, as they will examine, handle or modify the request before passing it along to the next operator in the chain.

The following code snippet shows an example on how to create a chain that calls a mock API endpoint.

```swift
import Network

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

Network has the following built-in operators:

|       Operator          | Function |
| :---------------------|-----------|
| `ApplyEnvironment` |Applies an `Environment` to all requests passing through the pipeline.|
| `Autocancel` | This operator cancels all in-flight tasks. Should be used in conjunction with the `ResetGuard` operator, as the next operator in the chain. |
| `ModifyRequest` | This operator modifies all requests passing through the pipeline. |
| `ResetGuard` | This operator prevents resetting an already resetting pipeline. This operator should preceed the operator `Autocancel`. |
| `Throttle` | This operator allows for throttling requests. |
| `TransportOperator` | This is a terminal operator, meaning it should be the last one in the chain. This operator handles the actual request. If injected with an `URLSession` object, it will call its ``dataTask(with:completionHandler:)` method, starting the URL request. |

