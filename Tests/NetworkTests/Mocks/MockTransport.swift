import Foundation
import Network

final class MockTransport: Transport {
    
    struct MockTask: TransportTask {
        
        private let response: Result<(data: Data, response: URLResponse), Error>
        private var completion: (Data?, URLResponse?, Error?) -> Void
        private let delay: Double
        
        init(response: Result<(data: Data, response: URLResponse), Error>,
             completion: @escaping (Data?, URLResponse?, Error?) -> Void,
             delay: Double) {
            self.response = response
            self.completion = completion
            self.delay = delay
        }
        
        func cancel() {
            
        }
        
        func resume() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                switch self.response {
                case .failure(let error):
                    self.completion(nil, nil, error)
                case .success(let response):
                    self.completion(response.data, response.response, nil)
                }
            }
        }
    }

    private let response: Result<(data: Data, response: URLResponse), Error>
    private var delay: Double
    
    init(response: Result<(data: Data, response: URLResponse), Error>, delay: Double = 0) {
        self.response = response
        self.delay = delay
    }
    
    func send(_ request: URLRequest, _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> TransportTask {
        MockTask(response: response, completion: completion, delay: delay)
    }
    
    func update(delay: Double) {
        self.delay = delay
    }
}
