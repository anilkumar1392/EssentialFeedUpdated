//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 10/10/21.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // Arrange
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
        
        // Act
        
        // Assert
        XCTAssertNil(client.requestedURL)
    }

}
