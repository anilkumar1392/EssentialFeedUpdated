//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 19/02/22.
//

import Foundation
import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

  // 1. Does not delete cache upon creation.
  // 2. Save Request cache deletion.

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheonCreation() {
        
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    
    func test_save_requestCacheDeletion() {
        
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        
        let items = [uniqueItem(), uniqueItem()]
        loader.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // MARK: - Helper methods
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, image: anyUrl())
    }
    
    private func anyUrl() -> URL {
        return  URL(string: "https://any-url.com")!
    }
}
