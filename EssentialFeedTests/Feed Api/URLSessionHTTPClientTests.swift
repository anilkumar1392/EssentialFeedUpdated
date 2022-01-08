//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 28/11/21.
//

import Foundation
import XCTest
import EssentialFeed

/*
protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}*/

class URLSessionHTTPClient: HTTPClient {

    let session: URLSession //HTTPSession //URLSession
    
    init(session: URLSession = .shared) { // HTTPSession
        self.session = session
    }
    
    struct UnexpectedValuesRepresentaiton: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data , response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentaiton()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    /*
    func test_getFromUrl_createsDataTaskWithUrl() {
        let url = URL(string: "https://any-url.com")!
        let urlSession = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: urlSession)
        sut.get(from: url)
        
        XCTAssertEqual(urlSession.receivedUrls, [url])
    }*/
    
    /*
    func test_getFromUrl_resumesDataTaskWithUrl() {
        let url = URL(string: "https://any-url.com")!
        // let urlSession = URLSessionSpy()
        let task = URLSessionDataTaskSpy()

        // urlSession.stub(url: url, task: task)
        let sut = URLSessionHTTPClient() // URLSessionHTTPClient(session: urlSession)
        sut.get(from: url) { _ in
        }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    } */
    
    
    // By doing this like observing avery request we lose the value of checking the urls so that is a different concern and we can move it to a diff test.
    
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromUrl_performGetRequestWithUrl() {
        let url = anyUrl()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in
        }
        
        /*
         if we invoke the get method with the url we expect
         A request to be executed with the right url and method.
         */
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_getFromUrl_failsOnRequestError() {
                
        // Arrange
        let error = NSError(domain: "any error", code: 1)
        // let session = URLSessionSpy()
        // session.stub(url: url, error: error)

        /*
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        // let sut = URLSessionHTTPClient(session: session)
        // let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for fulfill")
        
        makeSUT().get(from: anyUrl()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)

            default:
                XCTFail("Expected failure but got \(result) instead")

            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        */
        
        let receivedError: NSError? = resultErrorFor(data: nil, response: nil, error: error) as NSError?
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
        
    }
    
    func test_getFromUrl_failsOnAllNilValues() {
        /*
        URLProtocolStub.stub(data: nil, response: nil, error: nil)

        let exp = expectation(description: "wait for fulfill")
        
        makeSUT().get(from: anyUrl()) { result in
            switch result {
            case .failure: break
            default:
                XCTFail("Expected failure, got \(result) instead")

            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0) */
        
        
        let receivedError: NSError? = resultErrorFor(data: nil, response: nil, error: nil) as NSError?
        XCTAssertNotNil(receivedError)
    }
    
    func test_getFromUrl_failsForAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPUrlResponse(), error: nil) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPUrlResponse(), error: anyNSError()) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPUrlResponse(), error: anyNSError()) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPUrlResponse(), error: anyNSError()) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPUrlResponse(), error: anyNSError()) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPUrlResponse(), error: anyNSError()) as NSError?)
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPUrlResponse(), error: nil) as NSError?)

    }
    
    func test_getFromUrl_succeedOnHTTPUrlResponseWithData() {
        let data = anyData()
        let response = anyHTTPUrlResponse()
        
        let receivedValue = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.response.url, response.url)
    }
    
    func test_getFromUrl_succeedWithEmptyDataOnHTTPUrlResponseWithNilData() {
        let response = anyHTTPUrlResponse()
        
        let receivedValue = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedValue?.response.url, response.url)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyUrl() -> URL {
        return  URL(string: "https://any-url.com")!
    }
    
    private func anyData() -> Data {
        return "Any data".data(using: .utf8) ?? Data()
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any error", code: 0)
    }
    
    private func anyHTTPUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyUrl(),
                               statusCode: 200,
                               httpVersion: nil,
                               headerFields: nil) ?? HTTPURLResponse()
    }
    
    private func nonHTTPUrlResponse() -> URLResponse {
        return URLResponse(url: anyUrl(),
                           mimeType: nil,
                           expectedContentLength: 0,
                           textEncodingName: nil)
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for fulfill")
        
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyUrl()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    // MARK: - Helpers
    /*
    private class URLSessionSpy: HTTPSession /*URLSession */ {
        // var receivedUrls = [URL]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask // URLSessionDataTask
            let error: NSError?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: NSError? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask /* URLSessionDataTask */ {
            // receivedUrls.append(url)
            /*
            if let stub = stubs[url] {
                completionHandler(nil, nil, stub.error)
                return stub.task
            }*/
            
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for the \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task //FakeURLSessionDataTask()
        }
    }*/
    
    private class URLProtocolStub: URLProtocol {
        // var receivedUrls = [URL]()
        // private static var stubs = [URL: Stub]()
        private static var stubs: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            // stubs[url] = Stub(data: data, response: response, error: error)
            stubs = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            // guard let url = request.url else { return false }
            // return URLProtocolStub.stubs[url] != nil
            
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            /*
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            } */
            
            if let data = URLProtocolStub.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stubs?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
        }
    }
    
    
    /*
    private class FakeURLSessionDataTask: HTTPSessionTask /* URLSessionDataTask */ {
        func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask /* URLSessionDataTask */ {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
  */

}
