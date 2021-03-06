import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol TransportTask {
    func cancel()
    func resume()
}

extension URLSessionTask: TransportTask {}
