import XCTest
@testable import NetworkStack

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
            request.host = "gitlab.com"
            request.path = "v1\(request.path)"
            request.add(headers: ["X-API-KEY": "HelloWorld123FooBarBaz"])
            
            return request
        }

        XCTAssertEqual(request.host, "github.com")
        XCTAssertEqual(request.path, "/pkrll/network")
        XCTAssertNil(request.headers["X-API-KEY"])
        
        modifyRequest.send(request) { result in
            let request: Request
            
            switch result {
            case .failure(let error):
                request = error.request
            case .success(let response):
                request = response.request
            }
            
            XCTAssertEqual(request.host, "gitlab.com")
            XCTAssertEqual(request.path, "/v1/pkrll/network")
            XCTAssertEqual(request.headers["X-API-KEY"], "HelloWorld123FooBarBaz")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
}
