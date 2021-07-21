import XCTest
@testable import Network

final class ModifyRequestsTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.host = "github.com"
        request.path = "pkrll/network"
        
        return request
    }
    
    func testModifyRequest() {
        let expectation = XCTestExpectation(description: "Request")
        
        let modifyRequest = ModifyRequest { request in
            var request = request
            request.add(headers: ["X-API-KEY": "HelloWorld123FooBarBaz"])
            
            return request
        }
        
        let transport = MockTransport(response: .failure(MockError.unknown))
        modifyRequest.next = TransportOperator(transport: transport)
        
        XCTAssertNil(request.headers["X-API-KEY"])
        
        modifyRequest.send(request) { result in
            let request: Request
            
            switch result {
            case .failure(let error):
                request = error.request
            case .success(let response):
                request = response.request
            }
            
            XCTAssertEqual(request.headers["X-API-KEY"], "HelloWorld123FooBarBaz")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
}
