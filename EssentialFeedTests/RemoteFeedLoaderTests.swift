//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 10/10/21.
//

import XCTest
import EssentialFeed

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



/*
 Test specific method.
 Their is nothing wrong with subclassing but their are better approaches. we can use composition rather than Inheritance.
 */



class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // Arrange
        /*
         Test logic is now test type and we do nto have singleton any more
         */
        let client = HttpClientSpy()  //HTTPClient.shared
        //HTTPClient.shared = client
        let _ = makeSUT()
        
        // Act
        // Assert
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    
    func test_load_requestsDataFromUrL(){
        /*
         Test logic is now test type and we do nto have singleton any more
         */
        let url = URL(string: "https.goolge.com")!
        // let client = HttpClientSpy()  //HTTPClient.shared
        //HTTPClient.shared = client
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataTwice() {
        let url = URL(string: "https.goolge.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        // client.error = NSError(domain: "test", code: 0) Stub
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        
        //Stub replaced with capturing
        let clientError = NSError(domain: "test", code: 0)
        // client.completions[0](clientError)
        
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https.goolge.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HttpClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        //var error: Error?
        var completions = [(Error) -> Void]()
        
        func get(from url: URL?, completion: @escaping (Error) -> Void) {
            /*
            if let error = error {
                completion(error)
            }*/
            completions.append(completion)
            guard let url = url else {return}
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, index: Int = 0) {
            completions[index](error)
        }
    }
}
