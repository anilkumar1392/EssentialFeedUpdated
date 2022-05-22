//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 22/05/22.
//

import Foundation
import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMesages, [])
    }
    
    func test_validateCache_deleteCacheOnRetrivalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMesages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteLessThanSevenDayOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrival(with: feed.local, timestamp: lessThanSevenDaysTimeStamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve])
    }
    
    func test_validateCache_deleteSevenDayOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrival(with: feed.local, timestamp: sevenDaysTimeStamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deleteMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed() 
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrival(with: feed.local, timestamp: moreThanSevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMesages, [.retrieve, .deleteCachedFeed])
    } 
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()

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


