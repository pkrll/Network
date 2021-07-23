import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol Transport {
    func send(_ request: URLRequest, _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> TransportTask
}

extension URLSession: Transport {
    public func send(_ request: URLRequest,
                     _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> TransportTask {
        dataTask(with: request, completionHandler: completion)
    }
}
