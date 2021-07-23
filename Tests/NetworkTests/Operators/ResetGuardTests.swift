import XCTest
@testable import NetworkStack

final class ResetGuardTests: XCTestCase {
    
    private var request: Request { Request(.get) }
    
    func testResetGuard() {
        let expectation = XCTestExpectation(description: "Request")
        
        let mockOperator = MockOperator()
        let resetGuard = ResetGuard()
        resetGuard.next = mockOperator
        resetGuard.send(request) { _ in }
        
        resetGuard.reset {
            XCTAssertTrue(mockOperator.hasResetted)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testResetGuardWithAutocancel() {
        let expectations = [
            XCTestExpectation(description: "Completion"),
            XCTestExpectation(description: "Cancellation"),
            XCTestExpectation(description: "Reset")
        ]
        
        let error = URLError(.unknown)
        let transport = MockTransport(response: .failure(error), delay: 2)
        let transportOperator = TransportOperator(transport: transport)
        let mockOperator = MockOperator(next: transportOperator)
        let autocancel = Autocancel(next: mockOperator)
        let resetGuard = ResetGuard(next: autocancel)

        let task = resetGuard.send(request) { result in
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
        
        resetGuard.reset {
            XCTAssertTrue(mockOperator.hasResetted)
            XCTAssertTrue(mockOperator.hasCancelled)
            expectations[2].fulfill()
        }
        
        wait(for: expectations, timeout: 10)
    }
}
