//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 10/10/21.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https.goolge.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // Arrange
        let client = HTTPClient.shared
        let _ = RemoteFeedLoader()
        
        // Act
        
        // Assert
        XCTAssertNil(client.requestedURL)
    }

    
    func test_load_requestDataFromUrL(){
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
