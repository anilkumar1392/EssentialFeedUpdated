//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 10/10/21.
//

import XCTest


class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        /*
         In production code we do not want to set aa proprety but we want to call a method to get data from Url.
         
         1. Move the test logic from Remote loader to HttpCLient
         2. We don't want requestedUrl as this is just for testing not in production so Let's move this to a different class by making HttpClient a var.
         3. Move the test logic to a new class HttpClientSpy subclass of HTTPClient
         */
         
        //1.  HTTPClient.shared.requestedURL = URL(string: "https.goolge.com")
        //2. HTTPClient.shared.get(from: URL(string: "https.goolge.com"))
        
        client.get(from: url)
        
        /*
         Above we are mixing the responsiblity
         1. Responsibility of Invoking the get method.
         2. Responsibility of locating this shared object.
         
         /*
          By using Singleton I know how to locate the instance I'm using and I dont need to konw.
          So by using Dependency Injection we can remove this responsibilty and we ahve more control.
          */
         
        */
    }
}

/*
class HTTPClient {
    /*
     As we are usign Dependecy Injection we do not need shared instance.
     */

    // static var shared = HTTPClient()
    
    /*
     Not a singleton anymore private init can be removed
     */
    //private init() {}
    func get(from url: URL?) {}
} */

protocol HTTPClient {
    func get(from url: URL?)
}

/*
 Test specific method.
 Their is nothing wrong with subclassing but their are better approaches. we can use composition rather than Inheritance.
 */

class HttpClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL?) {
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
        let url = URL(string: "https.goolge.com")!
        let client = HttpClientSpy()  //HTTPClient.shared
        //HTTPClient.shared = client
        let _ = RemoteFeedLoader(url: url, client: client)
        
        // Act
        
        // Assert
        XCTAssertNil(client.requestedURL)
    }

    
    func test_load_requestDataFromUrL(){
        /*
         Test logic is now test type and we do nto have singleton any more
         */
        let url = URL(string: "https.goolge.com")!
        let client = HttpClientSpy()  //HTTPClient.shared
        //HTTPClient.shared = client
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requestedURL, url)
    }
}
