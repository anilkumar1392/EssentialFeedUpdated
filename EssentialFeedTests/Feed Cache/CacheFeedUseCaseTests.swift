//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 19/02/22.
//

import Foundation
import XCTest

class LocalFeedLoader {
    
    let store: FeedStore?
    
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

 // 1. Does not delete cache upon creation
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheonCreation() {
        
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
