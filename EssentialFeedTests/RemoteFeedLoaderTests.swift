//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 10/10/21.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        /*
         In production code we do not want to set aa proprety but we want to call a method to get data from Url.
         
         1. Move the test logic from Remote loader to HttpCLient
         2. We don't want requestedUrl as this is just for testing not in production so Let's move this to a different class by making HttpClient a var.
         3. Move the test logic to a new class HttpClientSpy subclass of HTTPClient
         */
        // HTTPClient.shared.requestedURL = URL(string: "https.goolge.com")
        HTTPClient.shared.get(from: URL(string: "https.goolge.com"))
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    /*
     Not a singleton anymore private init can be removed
     */
    //private init() {}
    func get(from url: URL?) {}
}


/*
 Test specific method.
 */
class HttpClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL?) {
        guard let url = url else {return}
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // Arrange
        /*
         Test logic is now test type and we do nto have singleton any more
         */
        let client = HttpClientSpy()  //HTTPClient.shared
        HTTPClient.shared = client
        let _ = RemoteFeedLoader()
        
        // Act
        
        // Assert
        XCTAssertNil(client.requestedURL)
    }

    
    func test_load_requestDataFromUrL(){
        /*
         Test logic is now test type and we do nto have singleton any more
         */
        let client = HttpClientSpy()  //HTTPClient.shared
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
