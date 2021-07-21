import XCTest
@testable import Network

final class ThrottleTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "pkrll/network"
        
        return request
    }
    
    func testThrottlePolicyNever() {
        let expectations = [
            XCTestExpectation(description: "Request 1"),
            XCTestExpectation(description: "Request 2")
        ]
        
        var request = request
        request.throttle = .never
        
        let throttle = Throttle(count: 1)
        let transport = MockTransport(response: .failure(MockError.unknown), delay: 2)
        throttle.next = TransportOperator(transport: transport)
        
        var start: TimeInterval = 0
        throttle.send(request) { _ in
            expectations[0].fulfill()
            start = CFAbsoluteTimeGetCurrent()
        }
        
        transport.update(delay: 0)
        
        throttle.send(request) { _ in
            expectations[1].fulfill()
            XCTAssertEqual(start, 0)
        }
        
        wait(for: expectations, timeout: 10)
    }

    func testThrottle() {
        let expectations = [
            XCTestExpectation(description: "Request 1"),
            XCTestExpectation(description: "Request 2")
        ]
        
        var request = request
        request.throttle = .always
        
        let throttle = Throttle(count: 1)
        let transport = MockTransport(response: .failure(MockError.unknown), delay: 2)
        throttle.next = TransportOperator(transport: transport)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        throttle.send(request) { _ in
            expectations[0].fulfill()
        }
        
        transport.update(delay: 0)
        
        throttle.send(request) { _ in
            expectations[1].fulfill()
            
            let difference = CFAbsoluteTimeGetCurrent() - start
            XCTAssertTrue((2...3).contains(difference))
        }
        
        wait(for: expectations, timeout: 10)
    }
}
