import Foundation

public struct Request {
    public let id: UUID = UUID()
    public private(set) var method: Method
    public private(set) var headers: [String: String]
    public var body: Body = EmptyBody()
    
    public var scheme: String { urlComponents.scheme ?? "https" }
    
    public var url: URL? { urlComponents.url }
    
    public var host: String? {
        get { urlComponents.host }
        set { urlComponents.host = newValue }
    }
    
    public var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }
    
    private var urlComponents: URLComponents
    private var options: [ObjectIdentifier: Any] = [:]
    
    public init(_ method: Method = .get, headers: [String: String] = [:]) {
        self.method = method
        self.headers = headers
        self.urlComponents = URLComponents()
        self.urlComponents.scheme = scheme
    }
    
    public subscript<Option: RequestOption>(option type: Option.Type) -> Option.Value {
        get {
            let identifier = ObjectIdentifier(type)
            guard let value = options[identifier] as? Option.Value else {
                return type.defaultOption
            }
            
            return value
        }
        set {
            let identifier = ObjectIdentifier(type)
            options[identifier] = newValue
        }
    }
    
    public mutating func add(headers: [String: String]) {
        headers.forEach { field, value in
            self.headers[field] = value
        }
    }

    public mutating func add(queryItems: [URLQueryItem]) {
        guard !queryItems.isEmpty else {
            return
        }
        
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = []
        }
        
        queryItems.forEach { query in
            urlComponents.queryItems?.append(query)
        }
    }
}
