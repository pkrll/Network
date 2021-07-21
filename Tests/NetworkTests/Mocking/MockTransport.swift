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
    
    init(response: Result<(data: Data, response: URLResponse), Error>) {
        self.response = response
    }
    
    func send(_ request: URLRequest, _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> TransportTask {
        self.completion = completion
        return MockTask(transport: self)
    }
    
    private func complete() {
        switch response {
        case .failure(let error):
            completion?(nil, nil, error)
        case .success(let response):
            completion?(response.data, response.response, nil)
        }
    }
    
}
