//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 21/06/22.
//

import Foundation
import XCTest
import EssentialFeed

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestStoreDataFromURL() {
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: anyUrl()) { result in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: anyUrl())])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyNSError()
            store.complete(with: retrievalError)
        }
        
        /*
        let retrievalError = anyNSError()

        let exp = expectation(description: "wait for load completion")
        _ = sut.loadImageData(from: anyUrl(), completion: { result in
            
            switch result {
            case .failure(let error as LocalFeedImageDataLoader.Error):
                XCTAssertEqual(error, LocalFeedImageDataLoader.Error.failed)
                
            default:
                XCTFail("Expected to complete with failure, got \(result) instead")
            }
            
            exp.fulfill()
        })
          
        store.complete(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
         */
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        expect(sut, toCompleteWith: .success(foundData)) {
            store.complete(with: foundData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyUrl()) { received.append($0) }
        
        task.cancel()
        store.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDelvierResultafterSUTInstacneHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyUrl(), completion: { received.append($0) })
        
        sut = nil
        store.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expecetd no result after sut instacne has been deallocated")
    }
}

// MARK: - Helepr methods

extension LocalFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        
        _ = sut.loadImageData(from: anyUrl(), completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
                  .failure(let expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        })
          
        action()
        wait(for: [exp], timeout: 1.0)
    }
}

extension LocalFeedImageDataLoaderTests {
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private var completions = [(FeedImageDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
