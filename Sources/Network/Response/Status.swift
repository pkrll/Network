import Foundation

public struct Status {
    
    //
    // MARK: - Informational - 1xx
    //
    
    /// Indicates that everything so far is OK and that the client should continue the request, or ignore the response
    /// if the request is already finished.
    public static let `continue` = Self(rawValue: 100)
    /// Sent in response to an `Upgrade` request header from the client, and indicates the protocol the server is
    /// switching to.
    public static let switchingProtocols = Self(rawValue: 101)
    /// Indicates that the server has received and is processing the request, but no response is available yet.
    public static let processing = Self(rawValue: 102)
    /// Primarily intended to be used with the `Link` header, letting the user agent start preloading resources while
    /// the server prepares a response.
    public static let earlyHints = Self(rawValue: 103)
    
    //
    // MARK: - Success - 2xx
    //
    
    /// Indicates that the The request has succeeded.
    ///
    /// - Note: The meaning of the success depends on the ``http`` method:
    ///     - ``GET``: The resource has been fetched and is transmitted in the message body.
    ///     - ``HEAD``: The representation headers are included in the response without any message body.
    ///     - ``PUT`` or ``POST``: The resource describing the result of the action is transmitted in the message body.
    ///     - ``TRACE``: The message body contains the request message as received by the server.
    public static let ok = Self(rawValue: 200)
    /// The request has succeeded and a new resource has been created as a result. This is typically the response sent
    /// after POST requests, or some PUT requests.
    public static let created = Self(rawValue: 201)
    /// The request has been received but not yet acted upon.
    public static let accepted = Self(rawValue: 202)
    /// The server is a transforming proxy (e.g. a Web accelerator) that received a 200 OK from its origin, but is
    /// returning a modified version of the origin's response.
    public static let nonAuthoritativeInformation = Self(rawValue: 203)
    /// The server successfully processed the request and is not returning any content.
    public static let noContent = Self(rawValue: 204)
    /// The server successfully processed the request, and indicates that the user-agent should reset the document
    /// which sent this request.
    public static let resetContent = Self(rawValue: 205)
    /// This response code is used when the ``Range`` header is sent from the client to request only part of a resource.
    public static let partialContent = Self(rawValue: 206)
    /// Conveys information about multiple resources, for situations where multiple status codes might be appropriate.
    /// - Note: This is a WebDAV extension status code.
    public static let multiStatus = Self(rawValue: 207)
    /// The members of a DAV binding have already been enumerated in a previous reply to this request, and are not being
    /// included again.
    /// - Note: This is a WebDAV extension status code.
    public static let alreadyReported = Self(rawValue: 208)
    /// The server has fulfilled a GET request for the resource, and the response is a representation of the result of
    /// one or more instance-manipulations applied to the current instance.
    /// - Note: This is a WebDAV extension status code.
    public static let IMUsed = Self(rawValue: 226)
    
    //
    // MARK: - Redirection - 3xx
    //
    
    /// Indicates multiple options for the resource from which the client may choose.
    public static let multipleChoices = Self(rawValue: 300)
    /// The URL of the requested resource has been changed permanently. The new URL is given in the response.
    public static let movedPermanently = Self(rawValue: 301)
    /// The URI of requested resource has been changed temporarily. Further changes in the URI might be made in the
    /// future. Therefore, this same URI should be used by the client in future requests.
    public static let found = Self(rawValue: 302)
    /// The response to the request can be found under another URI using a GET method.
    public static let seeOther = Self(rawValue: 303)
    /// Indicates that the resource has not been modified since the version specified by the request headers
    /// If-Modified-Since or If-None-Match.
    public static let notModified = Self(rawValue: 304)
    /// The requested resource is available only through a proxy, the address for which is provided in the response.
    public static let useProxy = Self(rawValue: 305)
    /// No longer used. Originally meant "Subsequent requests should use the specified proxy.
    public static let switchProxy = Self(rawValue: 306)
    /// The request should be repeated with another URI.
    public static let temporaryRedirect = Self(rawValue: 307)
    /// The request and all future requests should be repeated using another URI.
    public static let permenantRedirect = Self(rawValue: 308)
    
    //
    // MARK: - Client Error - 4xx
    //
    
    /// The server cannot or will not process the request due to an apparent client error.
    public static let badRequest = Self(rawValue: 400)
    /// Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not
    /// yet been provided.
    public static let unauthorized = Self(rawValue: 401)
    /// The content available on the server requires payment.
    ///
    /// - Note: This response code is reserved for future use. The initial aim for creating this code was using it
    ///         for digital payment systems, however this status code is used very rarely and no standard convention
    ///         exists.
    public static let paymentRequired = Self(rawValue: 402)
    /// The request was a valid request, but the server is refusing to respond to it. Unlike 401, the client's identity
    /// is known to the server.
    public static let forbidden = Self(rawValue: 403)
    /// The requested resource could not be found but may be available in the future.
    ///
    /// - Note: In an API, this can also mean that the endpoint is valid but the resource itself does not exist. Servers
    ///         may also send this response instead of 403 to hide the existence of a resource from an unauthorized client.
    public static let notFound = Self(rawValue: 404)
    /// A request method is not supported for the requested resource. e.g. a GET request on a form which requires data to
    /// be presented via POST
    public static let methodNotAllowed = Self(rawValue: 405)
    /// The requested resource is capable of generating only content not acceptable according to the Accept headers sent
    /// in the request.
    public static let notAcceptable = Self(rawValue: 406)
    /// The client must first authenticate itself with the proxy.
    public static let proxyAuthenticationRequired = Self(rawValue: 407)
    /// The server timed out waiting for the request.
    public static let requestTimeout = Self(rawValue: 408)
    /// Indicates that the request could not be processed because of conflict in the request, such as an edit conflict
    /// between multiple simultaneous updates.
    public static let conflict = Self(rawValue: 409)
    /// Indicates that the resource requested is no longer available and will not be available again.
    public static let gone = Self(rawValue: 410)
    /// The request did not specify the length of its content, which is required by the requested resource.
    public static let lengthRequired = Self(rawValue: 411)
    /// The server does not meet one of the preconditions that the requester put on the request.
    public static let preconditionFailed = Self(rawValue: 412)
    /// The request is larger than the server is willing or able to process.
    public static let payloadTooLarge = Self(rawValue: 413)
    /// The URI provided was too long for the server to process.
    public static let URITooLong = Self(rawValue: 414)
    /// The request entity has a media type which the server or resource does not support.
    public static let unsupportedMediaType = Self(rawValue: 415)
    /// The client has asked for a portion of the file (byte serving), but the server cannot supply that portion.
    public static let rangeNotSatisfiable = Self(rawValue: 416)
    /// The server cannot meet the requirements of the Expect request-header field.
    public static let expectationFailed = Self(rawValue: 417)
    /// This HTTP status is used as an Easter egg in some websites.
    public static let teapot = Self(rawValue: 418)
    /// The request was directed at a server that is not able to produce a response.
    public static let misdirectedRequest = Self(rawValue: 421)
    /// The request was well-formed but was unable to be followed due to semantic errors.
    public static let unprocessableEntity = Self(rawValue: 422)
    /// The resource that is being accessed is locked.
    public static let locked = Self(rawValue: 423)
    /// The request failed due to failure of a previous request (e.g., a PROPPATCH).
    public static let failedDependency = Self(rawValue: 424)
    /// The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.
    public static let upgradeRequired = Self(rawValue: 426)
    /// The origin server requires the request to be conditional.
    public static let preconditionRequired = Self(rawValue: 428)
    /// The user has sent too many requests in a given amount of time.
    public static let tooManyRequests = Self(rawValue: 429)
    /// The server is unwilling to process the request because either an individual header field, or all the header
    /// fields collectively, are too large.
    public static let requestHeaderFieldsTooLarge = Self(rawValue: 431)
    /// Used to indicate that the server has returned no information to the client and closed the connection.
    public static let noResponse = Self(rawValue: 444)
    /// A server operator has received a legal demand to deny access to a resource or to a set of resources that
    /// includes the requested resource.
    public static let unavailableForLegalReasons = Self(rawValue: 451)
    /// An expansion of the 400 Bad Request response code, used when the client has provided an invalid client certificate.
    public static let SSLCertificateError = Self(rawValue: 495)
    /// An expansion of the 400 Bad Request response code, used when a client certificate is required but not provided.
    public static let SSLCertificateRequired = Self(rawValue: 496)
    /// -An expansion of the 400 Bad Request response code, used when the client has made a HTTP request to a port
    /// listening for HTTPS requests.
    public static let HTTPRequestSentToHTTPSPort = Self(rawValue: 497)
    /// Used when the client has closed the request before the server could send a response.
    public static let clientClosedRequest = Self(rawValue: 499)
    
    //
    // MARK: - Server Error - 5xx
    //
    
    /// A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
    public static let internalServerError = Self(rawValue: 500)
    /// The server either does not recognize the request method, or it lacks the ability to fulfill the request.
    public static let notImplemented = Self(rawValue: 501)
    /// The server was acting as a gateway or proxy and received an invalid response from the upstream server.
    public static let badGateway = Self(rawValue: 502)
    /// The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a
    /// temporary state.
    public static let serviceUnavailable = Self(rawValue: 503)
    /// The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
    public static let gatewayTimeout = Self(rawValue: 504)
    /// The server does not support the HTTP protocol version used in the request.
    public static let HTTPVersionNotSupported = Self(rawValue: 505)
    /// Transparent content negotiation for the request results in a circular reference.
    public static let variantAlsoNegotiates = Self(rawValue: 506)
    /// The server is unable to store the representation needed to complete the request.
    public static let insufficientStorage = Self(rawValue: 507)
    /// The server detected an infinite loop while processing the request.
    public static let loopDetected = Self(rawValue: 508)
    /// Further extensions to the request are required for the server to fulfill it.
    public static let notExtended = Self(rawValue: 510)
    /// The client needs to authenticate to gain network access.
    public static let networkAuthenticationRequired = Self(rawValue: 511)
    
    public let rawValue: Int
}
