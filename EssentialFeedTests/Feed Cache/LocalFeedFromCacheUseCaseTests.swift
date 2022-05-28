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
 
 1. Devliers images when cache is less than seven days old
 2. Delviers no images on seven days old cache
 
 1. Delete cache on retrival error
 2. Should not delete the cache on empty cache
 
 ###Load Feed From Cache Use Case

 #### Primary course:
 1. Execute "Load Image Feed" command with above data.
 2. System fetchesretrieves feed data from cache.
 3. System validates cache is less than seven days old.
 4. System creates image feed from cached data.
 5. System delivers image feed.

 #### Retrieval Error course (sad path):
 1. System deletes cache.
 2. System delivers error.

 #### Expired cache course (sad path):
 1. System deletes cache.
 2. System delivers no feed images.

 #### Empty cache course (sad path):
 1. System delivers no feed images.
 
 Command–Query Separation Principle:  So seperate quering from command with side effects
 
 Seperating loading from validating:
 
 because this is volating Command-Query principle.
 we are fetcing and validating at same place.

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
        
        expect(sut, toCompleteWith: .failure(retrivalError)) {
            store.completeRetrival(with:  retrivalError)
        }
        /*
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
         */
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrivalWithEmptyCache()
        }
        
        /*
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
         */
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() { // test_load_deliversCachedImagesOnLessThanSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() { //test_load_deliversNoImagesOnSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() { // test_load_deliversNoImagesOnMoreThanSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
        }
    }
    
    /*
     By following  Command–Query Separation Principle:  So seperate quering from command with side effects
     we are seperating validating from load or fetching and moving this validation test to validation file.

     */
    func test_load_hasNoSideEffectOnRetrivalError() { // test_load_deleteCacheOnRetrivalError
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }

    func test_load_hasNoSideEffectOnEmptyCache() { // test_load_doesNotDeleteCacheOnEmptyCache
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() { // test_load_notDeleteCacheOnLessThanSevenDayOldCache, test_load_hasNoSideEffectOnLessThanSevenDayOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() { // test_load_deleteCacheOnSevenDayOldCache, test_load_hasNoSideEffectOnSevenDayOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() { // test_load_deleteCacheOnMoreThanSevenDaysOldCache, test_load_hasNoSideEffectOnMoreThanSevenDaysOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSutInstanceHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResult.append($0) }
        
        sut = nil
        store.completeRetrivalWithEmptyCache()
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    // MARK: - Heleprs
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for expectation for fulfill")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                
            case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
 
}

