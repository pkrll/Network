import Foundation

public protocol TransportTask {
    func cancel()
    func resume()
}

extension URLSessionTask: TransportTask {}
