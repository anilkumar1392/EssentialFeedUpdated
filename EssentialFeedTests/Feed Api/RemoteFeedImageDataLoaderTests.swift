//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 20/06/22.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://any-url.com")!

        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://any-url.com")!

        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // Delviers error on client error
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let expectedError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.complete(with: expectedError)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataOnNon200HTTPSResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPSResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: emptyData())
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty".utf8)

        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDelvierResultAfterInstanceHasBeenDeallocated() {
        let client = HttpClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        let url = URL(string: "http://any-url.com")!

        var capturedResult = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: url, completion: { result in
            capturedResult.append(result)
        })
        
        sut = nil
        client.complete(with: anyNSError())
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    // Cancels load task on cancel request.
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "http://any-url.com")!

        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled request urls until ask is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")

    }
    
    // Does not delivers resutl after cancelling task
    
    func test_loadDataImageFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var capturedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyUrl()) { capturedResult.append($0) }
        task.cancel()
        
        client.complete(with: anyNSError())
        client.complete(withStatusCode: 200, data: nonEmptyData)

        XCTAssertTrue(capturedResult.isEmpty, "Expected no resutl after task is cancelled")
    }

}

// MARK: - RemoteFeedImageDataLoaderTests

extension RemoteFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageDataLoader, client: HttpClientSpy){
        let client = HttpClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expecetdResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = URL(string: "http://any-url.com")!
        let exp = expectation(description: "wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expecetdResult)  {
            case let (.success(receivedData), .success(expecetdData)):
                XCTAssertEqual(receivedData, expecetdData, file: file, line: line)

            case let (.failure(retrievedError as NSError?), .failure(expecetdError as NSError?)):
                XCTAssertEqual(retrievedError, expecetdError, file: file, line: line)
                
            default:
                XCTFail("Expected to complete with \(expecetdResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
}
