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
 */
class LocalFeedFromCacheUseCaseTest: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMesages, [])
    }
    
    func test_load_requestCacheRetrival() {
        let (sut, store) = makeSUT()

        sut.load()
        
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
