//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 22/05/22.
//

import Foundation
import XCTest
import EssentialFeed

/*
 Separating queries and side-effects by following the Command-Query Separation principle
 Producing a reliable codebase history (always in a working state)
 Identifying Application-specific vs. Application-agnostic logic
 
 Command–Query Separation (CQS)
 Thus, in this lecture, we separate loading and validation into two use cases, implemented in distinct methods: load() and validateCache().

 It's a trade-off. Ideally, enumerations should be final (closed). We should strive to avoid adding more cases to enums as it breaks the contract with clients of our code (a violation of the open-closed principle!).
 */

class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMesages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrivalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache {_ in }
        store.completeRetrival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMesages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache {_ in }
        store.completeRetrivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache() { // test_validateCache_doesNotDeleteLessThanSevenDayOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache {_ in }
        store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_validateCache_deleteCacheOnExpiration() { // test_validateCache_deleteSevenDayOldCache
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache {_ in }
        store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deleteExpiredCache() { // test_validateCache_deleteMoreThanSevenDaysOldCache
        let feed = uniqueImageFeed() 
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache {_ in }
        store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve, .deleteCachedFeed])
    } 
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache {_ in }

        sut = nil
        store.completeRetrival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    // MARK: - Heleprs
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

}


