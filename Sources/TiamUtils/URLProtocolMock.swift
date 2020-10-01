import Foundation

public protocol StubURLsProviding {
    static var stubURLs: [URL: Data] { get set }
}

public class URLProtocolMock<T: StubURLsProviding>: URLProtocol {
    public override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    public override class func canInit(with task: URLSessionTask) -> Bool {
        true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func stopLoading() { }

    public override func startLoading() {
        if let url = request.url {
            if let data = T.stubURLs[url] {
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            } else {
                let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: [:])!
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
    }
}
