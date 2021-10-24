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
         Test logic is now test type and we do not have singleton any more
         */
        let url = URL(string: "https.goolge.com")!
        // let client = HttpClientSpy()  //HTTPClient.shared
        //HTTPClient.shared = client
        let (sut,client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataTwice() {
        let url = URL(string: "https.goolge.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    // No Connectivity
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        // client.error = NSError(domain: "test", code: 0) Stub
        
        //var capturedError: RemoteFeedLoader.Error

        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        
        //Stub replaced with capturing
        let clientError = NSError(domain: "test", code: 0)
        // client.completions[0](clientError)
        
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    // Invalid Data
    func test_load_deliversErrorOnNon200HttpsResponse() {
        let (sut, client) = makeSUT()

        let sampleData = [199, 201, 300, 400, 500]
        sampleData.enumerated().forEach { index, code in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load { capturedError.append($0) }
            client.complete(withStatusCode: code, index: index)
            XCTAssertEqual(capturedError, [.invalidData])
        }
    }
    
    // 200 with invalid json.
    func test_load_deliversErrorOn200HttpsResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https.goolge.com")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        action()
        XCTAssertEqual(capturedError, [error], file: file, line: line)
    }
    
    private class HttpClientSpy: HTTPClient {
        //var requestedURLs = [URL]()
        //var error: Error?
        //var completions = [(Error) -> Void]()
        private var messges = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messges.map {$0.url}
        }
        
        func get(from url: URL?, completion: @escaping (HTTPClientResult) -> Void) {
            /*
            if let error = error {
                completion(error)
            }*/
            
            //completions.append(completion)
            
            guard let url = url else {return}
            //requestedURLs.append(url)
            messges.append((url,completion))

        }
        
        func complete(with error: Error, index: Int = 0) {
            //completions[index](error)
            messges[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                                statusCode: code,
                                                httpVersion: nil,
                                                headerFields: nil
            )!
            messges[index].completion(.success(data,response))
        }
    }
}
