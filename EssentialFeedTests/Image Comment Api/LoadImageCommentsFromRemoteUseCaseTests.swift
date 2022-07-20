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
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username")
        
        let (item2, item2JSON) = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")
        
        let items = [item1, item2]

        let sample = [200, 201, 250, 280, 299]
        
        sample.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items)) {
                let json = makeItemJson([item1JSON, item2JSON])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https.goolge.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)

        return (sut, client)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id" : id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
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
