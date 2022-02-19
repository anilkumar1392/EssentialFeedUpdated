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
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insertItems(items)
            } else {
                
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0 ) {
        deletionCompletions[index](nil)
    }
    
    func insertItems(_ items: [FeedItem]) {
        insertCallCount += 1
    }
}

  // 1. Does not delete cache upon creation.
  // 2. Save Request cache deletion.

class CacheFeedUseCaseTests: XCTestCase {
    
    /*
     We gererally se code base with tests that a method must call but
     we are writing test that a method does not call when it is not necessary.
     */
    
    // does not delete cache on creation
    // writing this to check that we are not calling wrong method at wrong time.
    func test_init_doesNotDeleteCacheOnCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
     // Save command request cache deletion.
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // Deleting something may fail so.
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: - Helper methods
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, image: anyUrl())
    }
    
    private func anyUrl() -> URL {
        return  URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any error", code: 0)
    }
}
