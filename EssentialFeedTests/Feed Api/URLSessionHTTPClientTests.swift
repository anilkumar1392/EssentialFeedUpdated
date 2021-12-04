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

class URLSessionHTTPClient {
    let session: URLSession //HTTPSession //URLSession
    
    init(session: URLSession = .shared) { // HTTPSession
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
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
    
    func test_getFromUrl_failsOnRequestError() {
        
        URLProtocolStub.startInterceptingRequests()
        
        // Arrange
        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        // let session = URLSessionSpy()
        // session.stub(url: url, error: error)

        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        // let sut = URLSessionHTTPClient(session: session)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for fulfill")
        
        sut.get(from: url) { result in
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
        URLProtocolStub.stopInterceptingRequests()
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
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
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
