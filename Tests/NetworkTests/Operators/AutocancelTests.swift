import XCTest
@testable import Network

final class AutocancelTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "pkrll/network"
        
        return request
    }
    
    func testAutocancel() {
        let expectation = XCTestExpectation(description: "Request")
        
        let transport = MockTransport(response: .failure(MockError.unknown), delay: 2)
        let transportOperator = TransportOperator(transport: transport)
        let autocancel = Autocancel(next: transportOperator)
        
        let task = autocancel.send(request) { _ in
            XCTFail("Expected cancel.")
        }
        
        task.addCancellation {
            expectation.fulfill()
        }
        
        autocancel.reset { }

        wait(for: [expectation], timeout: 10)
    }
}
