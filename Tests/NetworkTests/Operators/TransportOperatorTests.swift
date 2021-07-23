import XCTest
@testable import NetworkStack

final class TransportOperatorTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "pkrll/network"
        
        return request
    }
    
    func testFailure() {
        let expectation = XCTestExpectation(description: "Sending request.")
        
        let error = URLError(.unknown)
        let transport = MockTransport(response: .failure(error))
        let operation = TransportOperator(transport: transport)

        operation.send(request) { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error.code, .unknown)
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
        let expectations = [
            XCTestExpectation(description: "Completion"),
            XCTestExpectation(description: "Cancellation handler.")
        ]

        let error = URLError(.unknown)
        let transport = MockTransport(response: .failure(error), delay: 0.25)
        let operation = TransportOperator(transport: transport)

        let task = operation.send(request) { result in
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
        
        task.cancel()
        
        wait(for: expectations, timeout: 10)
    }
}
