import XCTest
@testable import Network

final class TransportOperatorTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "/pkrll/network"
        
        return request
    }
    
    func testFailure() {
        let expectation = XCTestExpectation(description: "Sending request.")
        
        let transport = MockTransport(response: .failure(MockError.unknown))
        let operation = TransportOperator(transport: transport)

        operation.send(request) { result in
            if case .failure(let error) = result,
               let error = error.underlyingError as? MockError {
                XCTAssertEqual(error, MockError.unknown)
            } else {
                XCTFail("Expected MockError.")
            }

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testSuccess() {
        let expectation = XCTestExpectation(description: "Sending request.")
        
        let data = "Hello World".data(using: .utf8)!
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
        let result = (data: data, response: response)
        let transport = MockTransport(response: .success(result))
        let operation = TransportOperator(transport: transport)

        operation.send(request) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data, data)
                XCTAssertEqual(response.status, .ok)
            default:
                XCTFail("Expected success.")
            }

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testCancel() {
        let expectation = XCTestExpectation(description: "Sending request.")

        let transport = MockTransport(response: .failure(MockError.unknown), delay: 0.25)
        let operation = TransportOperator(transport: transport)

        let task = operation.send(request) { _ in
            XCTFail("Expected cancel.")
        }
        
        task.addCancellation {
            expectation.fulfill()
        }
        
        task.cancel()
        
        wait(for: [expectation], timeout: 10)
    }
}
