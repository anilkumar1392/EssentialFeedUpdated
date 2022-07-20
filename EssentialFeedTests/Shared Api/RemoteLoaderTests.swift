//
//  RemoteLoader<String>Tests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 20/07/22.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase { // RemoteLoader<String>Tests
    
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

        let exp = expectation(description: "wait for expectation")
        
        let expectedResult: RemoteLoader<String>.Result = .failure(RemoteLoader<String>.Error.connectivity)
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
                
            case let (.failure(receivedFailure as RemoteLoader<String>.Error), .failure(expectedFailure as RemoteLoader<String>.Error)):
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
    
    // Added test foe mapper failure
    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })

        expect(sut, toCompleteWith: .failure(RemoteLoader<String>.Error.invalidData)) {
            client.complete(withStatusCode: 200, data: anyData())
        }
    }
    
    // Any data passed to a mapper that throws an error generates invalid data.
    
    func test_load_deliversMappedResponses() {
        let resource = "a resource"
        let (sut, client) = makeSUT { data, _ in
            String(data: data, encoding: .utf8)!
        }
        
        expect(sut, toCompleteWith: .success(resource)) {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        }
        
    }
    
    func test_load_doesNotDeliverResultAfterSutInstanceHasbeenDeallocated() {
        let url = URL(string: "https://anyurl.com")!
        let client = HttpClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in "any" })

        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https.goolge.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: RemoteLoader<String>, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        
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
    
    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
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
