import XCTest
@testable import NetworkStack

final class AutocancelTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "pkrll/network"
        
        return request
    }
    
    func testAutocancel() {
        let expectations = [
            XCTestExpectation(description: "Completion"),
            XCTestExpectation(description: "Cancellation")
        ]
        
        let error = URLError(.unknown)
        let transport = MockTransport(response: .failure(error), delay: 2)
        let transportOperator = TransportOperator(transport: transport)
        let autocancel = Autocancel(next: transportOperator)
        
        let task = autocancel.send(request) { result in
            guard case .failure(let error) = result else {
                XCTFail("Expected cancel.")
                return
            }

            XCTAssertEqual(error.code, .cancelled)
            expectations[0].fulfill()
        }
        
        task.addCancellation {
            expectations[1].fulfill()
        }
        
        autocancel.reset { }

        wait(for: expectations, timeout: 10)
    }
}
