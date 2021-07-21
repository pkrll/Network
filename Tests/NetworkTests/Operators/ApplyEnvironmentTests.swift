import XCTest
@testable import Network

final class ApplyEnvironmentTests: XCTestCase {
    
    private var request: Request {
        var request = Request(.get)
        request.path = "pkrll/network"
        
        return request
    }
    
    func testApplyEnvironment() {
        let expectation = XCTestExpectation(description: "Request")
        let environment = Environment(host: "gitlab.com",
                                      pathPrefix: "v1",
                                      headers: ["X-API-KEY": "HelloWorld123FooBarBaz"],
                                      query: [.init(name: "query", value: "value")])
        let applyEnvironment = ApplyEnvironment(environment: environment)

        XCTAssertNil(request.host)
        XCTAssertEqual(request.path, "/pkrll/network")
        XCTAssertNil(request.headers["X-API-KEY"])
        XCTAssertNil(request.url?.query)
        
        applyEnvironment.send(request) { result in
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
            XCTAssertEqual(request.url?.query, "query=value")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testApplyEnvironmentDefault() {
        let expectation = XCTestExpectation(description: "Request")
        let environment = Environment(host: "gitlab.com",
                                      pathPrefix: "v1",
                                      headers: ["X-API-KEY": "HelloWorld123FooBarBaz"],
                                      query: [.init(name: "query", value: "value")])
        let applyEnvironment = ApplyEnvironment(environment: environment)

        XCTAssertNil(request.host)
        XCTAssertEqual(request.path, "/pkrll/network")
        XCTAssertNil(request.headers["X-API-KEY"])
        XCTAssertNil(request.url?.query)
        
        var request = request
        request.environment = Environment(host: "github.com", pathPrefix: "api")
        
        applyEnvironment.send(request) { result in
            let request: Request
            
            switch result {
            case .failure(let error):
                request = error.request
            case .success(let response):
                request = response.request
            }
            
            XCTAssertEqual(request.host, "github.com")
            XCTAssertEqual(request.path, "/api/pkrll/network")
            XCTAssertNil(request.headers["X-API-KEY"])
            XCTAssertNil(request.url?.query)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
}
