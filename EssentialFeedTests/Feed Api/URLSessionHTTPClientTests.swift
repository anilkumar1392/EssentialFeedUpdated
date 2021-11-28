//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 28/11/21.
//

import Foundation
import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession //URLSession
    
    init(session: HTTPSession) {
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
    
    func test_getFromUrl_resumesDataTaskWithUrl() {
        let url = URL(string: "https://any-url.com")!
        let urlSession = URLSessionSpy()
        let task = URLSessionDataTaskSpy()

        urlSession.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: urlSession)
        sut.get(from: url) { _ in
        }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        // Arrange
        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "any error", code: 0)
        let session = URLSessionSpy()
        session.stub(url: url, error: error)

        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for fulfill")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)

            default:
                XCTFail("Expected failure but got \(result) instead")

            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
    }
    
    // MARK: - Helpers
    
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
    }
    
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

}
