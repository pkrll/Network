import XCTest
@testable import Network

final class ResetGuardTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "pkrll/network"
        
        return request
    }
    
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
}
