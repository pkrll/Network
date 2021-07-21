import Foundation
import Network

final class MockTransport: Transport {
    
    final class MockTask: TransportTask {
        
        private var transport: MockTransport?
        
        init(transport: MockTransport) {
            self.transport = transport
        }
        
        func cancel() {
            
        }
        
        func resume() {
            transport?.complete()
        }
    }

    private var completion: ((Data?, URLResponse?, Error?) -> Void)?
    private let response: Result<(data: Data, response: URLResponse), Error>
    private let delay: Double
    
    init(response: Result<(data: Data, response: URLResponse), Error>, delay: Double = 0) {
        self.response = response
        self.delay = delay
    }
    
    func send(_ request: URLRequest, _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> TransportTask {
        self.completion = completion
        return MockTask(transport: self)
    }
    
    private func complete() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            switch self.response {
            case .failure(let error):
                self.completion?(nil, nil, error)
            case .success(let response):
                self.completion?(response.data, response.response, nil)
            }
        }
    }
}
