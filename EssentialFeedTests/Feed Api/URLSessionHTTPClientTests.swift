//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 28/11/21.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
    
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromUrl_createsDataTaskWithUrl() {
        let url = URL(string: "https://any-url.com")!
        let urlSession = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: urlSession)
        sut.get(from: url)
        
        XCTAssertEqual(urlSession.receivedUrls, [url])
    }
    
    func test_getFromUrl_resumesDataTaskWithUrl() {
        let url = URL(string: "https://any-url.com")!
        let urlSession = URLSessionSpy()
        let task = URLSessionDataTaskSpy()

        urlSession.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: urlSession)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedUrls = [URL]()
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {
        }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }

}
