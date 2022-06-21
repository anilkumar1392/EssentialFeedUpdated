//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 21/06/22.
//

import Foundation
import XCTest
import EssentialFeed

// LocalFeedImageDataLoaderTests
class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
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
            store.completeRetrieval(with: retrievalError)
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
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()

        expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with: foundData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyUrl()) { received.append($0) }
        
        task.cancel()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDelvierResultafterSUTInstacneHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyUrl(), completion: { received.append($0) })
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expecetd no result after sut instacne has been deallocated")
    }
}

// tests for save operations

extension LoadFeedImageDataFromCacheUseCaseTests {
    func test_saveImageDataForURL_requestsImageDataInsertionForIURL() {
        let (sut, store) = makeSUT()

        sut.save(anyData(), for: anyUrl()) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: anyData(), for: anyUrl())])
    }
}

// MARK: - Helepr methods

extension LoadFeedImageDataFromCacheUseCaseTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        
        _ = sut.loadImageData(from: anyUrl(), completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
                  .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
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

extension LoadFeedImageDataFromCacheUseCaseTests {
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case insert(data: Data, for: URL)
            case retrieve(dataFor: URL)
        }
        
        private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
        private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()

        private(set) var receivedMessages = [Message]()

        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, for: url))
            insertionCompletions.append(completion)
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            retrievalCompletions.append(completion)
        }
        
        func completeRetrieval(with error: NSError, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
    }
}
