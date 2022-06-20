//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 20/06/22.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    private let client : HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url, completion: { _ in })
    }
    
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://any-url.com")!

        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
}

// MARK: - RemoteFeedImageDataLoaderTests

extension RemoteFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}

extension RemoteFeedImageDataLoaderTests {
    private class HttpClientSpy: HTTPClient {

        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }

    }
}
