import Foundation

public final class URLSessionOperator: Operator {
    
    private let session: Transport
    
    public init(session: Transport = URLSession.shared) {
        self.session = session
        super.init(next: nil)
    }
    
    public override func load(_ task: Task) {
        let urlRequest: URLRequest
        
        do {
            urlRequest = try task.request.convert()
        } catch let error as HttpError {
            return task.complete(with: .failure(error))
        } catch {
            return task.complete(with: .failure(.from(error, code: .invalidRequest, request: task.request)))
        }
        
        let dataTask = session.send(urlRequest) { (data, response, error) in
            let result = HttpResult(request: task.request, data: data, response: response, error: error)
            task.complete(with: result)
        }

        task.addCancellation {
            dataTask.cancel()
        }
        
        dataTask.resume()
    }
}
