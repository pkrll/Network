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
        
        let error = URLError(.unknown)
        let throttle = Throttle(count: 1)
        let transport = MockTransport(response: .failure(error), delay: 2)
        throttle.next = TransportOperator(transport: transport)
        
        var start: TimeInterval?
        throttle.send(request) { _ in
            expectations[0].fulfill()
            start = CFAbsoluteTimeGetCurrent()
        }
        
        transport.update(delay: 0)
        
        throttle.send(request) { _ in
            expectations[1].fulfill()
            XCTAssertNil(start)
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
        
        let error = URLError(.unknown)
        let throttle = Throttle(count: 1)
        let transport = MockTransport(response: .failure(error), delay: 2)
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
    
    func testThrottleReset() {
        let expectations = [
            XCTestExpectation(description: "Completion of task 1"),
            XCTestExpectation(description: "Cancellation of task 1"),
            XCTestExpectation(description: "Completion of task 2"),
            XCTestExpectation(description: "Cancellation of task 2"),
            XCTestExpectation(description: "Reset")
        ]
        
        let error = URLError(.unknown)
        let throttle = Throttle(count: 1)
        let transport = MockTransport(response: .failure(error), delay: 1)
        throttle.next = TransportOperator(transport: transport)
        
        var request = request
        request.throttle = .always
        
        let task1 = throttle.send(request) { result in
            guard case .failure(let error) = result else {
                XCTFail("Expected cancel.")
                return
            }
            
            XCTAssertEqual(error.code, .cancelled)
            expectations[0].fulfill()
        }
        
        task1.addCancellation {
            expectations[1].fulfill()
        }

        let task2 = throttle.send(request) { result in
            guard case .failure(let error) = result else {
                XCTFail("Expected cancel.")
                return
            }
            
            XCTAssertEqual(error.code, .cancelled)
            expectations[2].fulfill()
        }
        
        task2.addCancellation {
            expectations[3].fulfill()
        }
        
        throttle.reset {
            expectations[4].fulfill()
        }
        
        wait(for: expectations, timeout: 10)
    }
}
