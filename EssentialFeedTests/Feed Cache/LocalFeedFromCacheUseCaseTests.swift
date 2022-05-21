//
//  LocalFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 21/05/22.
//

import Foundation
import XCTest
import EssentialFeed

/*
 we are writing test case to load data from cache
 
 1. So first case is over creati̧on it should not call store
 2. when we load we want a cache retrival from the store
 
 when we request a cache retrival couple fo things can happen
 1. it can fail
 2. We can get expired cache
 3. we can get empty cahce
 */
class LocalFeedFromCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMesages, [])
    }
    
    func test_load_requestCacheRetrival() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrivalError = anyNSError()
        let exp = expectation(description: "wait for expectation for fulfill")
        
        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetrival(with:  retrivalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, retrivalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        let exp = expectation(description: "wait for expectation for fulfill")

        var receivedImages: [FeedImage]?
        sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("expected success, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetrivalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedImages, [])
    }
    
    // MARK: - Heleprs
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any error", code: 0)
    }
    
}
