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


// MARK: - Rename this to FeedItemsMapperTests

class LoadFeedFromRemoteUseCaseTests: XCTestCase { // RemoteFeedLoaderTests

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

        /*
        var capturedError = [RemoteFeedLoader.Result]()
        sut.load { capturedError.append($0) }*/
        
        let exp = expectation(description: "wait for expectation")
        
        let expectedResult: RemoteFeedLoader.Result = .failure(RemoteFeedLoader.Error.connectivity)
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
                
            case let (.failure(receivedFailure as RemoteFeedLoader.Error), .failure(expectedFailure as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedFailure, expectedFailure)
                
            default:
                XCTFail("Expected result is \(expectedResult) received reuslt is \(receivedResult) instead")
            }
            
            exp.fulfill()
            
        }
        
        
        //Stub replaced with capturing
        let clientError = NSError(domain: "test", code: 0)
        // client.completions[0](clientError)
        
        client.complete(with: clientError)
        
        wait(for: [exp], timeout: 1.0)
        // XCTAssertEqual(capturedError, [.failure(.connectivity)])
    }
    
    // Invalid Data
    func test_load_deliversErrorOnNon200HttpsResponse() {
        let (sut, client) = makeSUT()

        let sampleData = [199, 201, 300, 400, 500]
        sampleData.enumerated().forEach { index, code in
            /*
            var capturedError = [RemoteFeedLoader.Result]()
            sut.load { capturedError.append($0) }
            let json = makeItemJson([])
            client.complete(withStatusCode: code, data: json, index: index)
            XCTAssertEqual(capturedError, [.failure(.invalidData)])*/
            
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    // 200 with invalid json.
    func test_load_deliversErrorOn200HttpsResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        /*
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }*/
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    // Delivers No items with 200
    func test_load_deliversNoItemsOn200HttpsResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        /*
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        let data = Data("{\"items\": []}".utf8)
        client.complete(withStatusCode: 200, data: data)
        
        XCTAssertEqual(capturedResults, [.success([])])
        */
        
        expect(sut, toCompleteWith: .success([])) {
            //let data = Data("{\"items\": []}".utf8)
            let data = makeItemJson([])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_deliversItemsOn200HttpResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let (item1, item1JSON) = makeItem(
            id: UUID(),
            image: URL(string: "http://a-url.com")!
        )
        let (item2, item2JSON) = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            image: URL(string: "http://a-url.com")!
        )
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = makeItemJson([item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json)
        }
        
    }
    
    func test_load_doesNotDeliverResultAfterSutInstanceHasbeenDeallocated() {
        let url = URL(string: "https://anyurl.com")!
        let client = HttpClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https.goolge.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)

        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, image: URL) -> (model: FeedImage, json: [String: Any]){
        let item = FeedImage(id: id, description: description, location: location, url: image)
        let json = [
            "id" : id.uuidString,
            "description": description,
            "location": location,
            "image": image.absoluteString
        ].compactMapValues { $0 }
        return (item, json)
    }
    
    private func makeItemJson(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    /*
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedError = [RemoteFeedLoader.Result]()
        sut.load { capturedError.append($0) }
        action()
        XCTAssertEqual(capturedError, [.failure(error)], file: file, line: line)
    }*/
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        /*
        var capturedError = [RemoteFeedLoader.Result]()
        sut.load { capturedError.append($0) }*/
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got received result \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

// Testing mapper in isolation as previously we were testing them in integration which is not needed now.

/*
 we just assert the output for specific input.
 it is just input and output no infrastructure, no closure.
 */
extension LoadFeedFromRemoteUseCaseTests {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let sampleData = [199, 201, 300, 400, 500]
        let json = makeItemJson([])
        
        try sampleData.forEach { code in
            XCTAssertThrowsError(
                 try FeedItemMapper.map(data: json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOnNon200HTTPResponseWithInvalidJSON() {
        let invalidJson = Data("invalid-json".utf8)
        
        XCTAssertThrowsError(
            try FeedItemMapper.map(data: invalidJson, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOnNon200HTTPResponseWithEmptyJSONList() throws {
        let emptyJSONList = makeItemJson([])

        let result = try FeedItemMapper.map(data: emptyJSONList, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HttpResponseWithJSONItems() throws {
        let (item1, item1JSON) = makeItem(
            id: UUID(),
            image: URL(string: "http://a-url.com")!
        )
        let (item2, item2JSON) = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            image: URL(string: "http://a-url.com")!
        )
        
        let json = makeItemJson([item1JSON, item2JSON])
        let result = try FeedItemMapper.map(data: json, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item1, item2])
    }
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyUrl(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
