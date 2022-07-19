//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 18/07/22.
//

import Foundation
import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
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
        
        //var capturedError: RemoteImageCommentsLoader.Error

        /*
        var capturedError = [RemoteImageCommentsLoader.Result]()
        sut.load { capturedError.append($0) }*/
        
        let exp = expectation(description: "wait for expectation")
        
        let expectedResult: RemoteImageCommentsLoader.Result = .failure(RemoteImageCommentsLoader.Error.connectivity)
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
                
            case let (.failure(receivedFailure as RemoteImageCommentsLoader.Error), .failure(expectedFailure as RemoteImageCommentsLoader.Error)):
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
    func test_load_deliversErrorOnNon2xxHttpsResponse() {
        let (sut, client) = makeSUT()

        let sampleData = [199, 150, 300, 400, 500]
        sampleData.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData)) {
                let json = makeItemJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    // 200 with invalid json.
    func test_load_deliversErrorOn2xxHttpsResponseWithInvalidJson() {
        let (sut, client) = makeSUT()

        let sample = [200, 201, 250, 280, 299]
        
        sample.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData)) {
                let invalidJSON = Data("Invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }

    // Delivers No items with 200
    func test_load_deliversNoItemsOn2xxHttpsResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let sample = [200, 201, 250, 280, 299]

        sample.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                let data = makeItemJson([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversItemsOn2xxHttpResponseWithJSONItems() {
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
        
        let sample = [200, 201, 250, 280, 299]
        
        sample.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([item1, item2])) {
                let json = makeItemJson([item1JSON, item2JSON])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_doesNotDeliverResultAfterSutInstanceHasbeenDeallocated() {
        let url = URL(string: "https://anyurl.com")!
        let client = HttpClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)

        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https.goolge.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
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
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWithError error: RemoteImageCommentsLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedError = [RemoteImageCommentsLoader.Result]()
        sut.load { capturedError.append($0) }
        action()
        XCTAssertEqual(capturedError, [.failure(error)], file: file, line: line)
    }*/
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        /*
        var capturedError = [RemoteImageCommentsLoader.Result]()
        sut.load { capturedError.append($0) }*/
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
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
