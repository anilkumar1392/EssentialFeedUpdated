//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 19/02/22.
//

import Foundation
import XCTest
import EssentialFeed

/*
 one thing we need to take care is LocalFeedLoader is calling more than one method.
 1. so we need to make sure that methods are called and called in right order.
 
 NOW we have order dependency how to communcate with the store.
 
 we are using distinct property to check the invocation of the methods.
 solution: if we can combine all the received messages in one array we can solve this problem.
 */


class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionerror = error {
                completion(cacheDeletionerror)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insertItems(items, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
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
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMesages, [])
    }
    
     // Save command request cache deletion.
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
         // XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        XCTAssertEqual(store.receivedMesages, [.deleteCachedFeed])

    }
    
    // Deleting something may fail so.
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        // XCTAssertEqual(store.insertions.count, 0)
        XCTAssertEqual(store.receivedMesages, [.deleteCachedFeed])

    }
    
    /* // This test is covered in test written next to it
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    } */
    
    // Save with timestamp
    func test_save_requestsNewCacheInsertionTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMesages, [.deleteCachedFeed, .insert(items, timestamp)])

        // XCTAssertEqual(store.insertions.count, 1)
        // XCTAssertEqual(store.insertions.first?.items, items)
        // XCTAssertEqual(store.insertions.first?.timestamp, timestamp)

    }
    
     // save to should fail on deletion error
    func test_save_failOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        /*
        let items = [uniqueItem(), uniqueItem()]
        var receivedError: Error?
        
        let exp = expectation(description: "wait for save completion")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, deletionError)
        */
        
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    // When insertion fails
    func test_save_failOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
        
        /*
        let items = [uniqueItem(), uniqueItem()]
        var receivedError: Error?
        
        let exp = expectation(description: "wait for save completion")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)

        wait(for: [exp], timeout: 2.0)

        XCTAssertEqual(receivedError as NSError?, insertionError)
        */

    }
    
    func test_save_succeeddOnSussfullCacheInsertion () {
        /*
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        var receivedError: Error?
        
        let exp = expectation(description: "wait for save completion")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }

        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()

        wait(for: [exp], timeout: 2.0)

        XCTAssertNil(receivedError) */
        
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
        
    }
    
    /*
     Proper Memory-Management of Captured References Within Deeply Nested Closures.
     */
    
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults = [Error?]()
        sut?.save([uniqueItem()], completion: { error in
            receivedResults.append(error)
        })
    
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults = [Error?]()
        sut?.save([uniqueItem()], completion: { error in
            receivedResults.append(error)
        })
    
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    // MARK: - Helper methods
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expecetdError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for save completion")
        var receivedError: Error?

        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 2.0)

        XCTAssertEqual(receivedError as NSError?, expecetdError)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
    
    private class FeedStoreSpy: FeedStore {

        var deletionCompletions = [DeletionCompletion]()
        var insertionCompletions = [InsertionCompletion]()

        // var deleteCachedFeedCallCount = 0
        // var insertCallCount = 0
        // var insertions = [(items: [FeedItem], timestamp: Date)]()
        
        enum ReceivedMessages: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        
        private(set) var receivedMesages = [ReceivedMessages]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            // deleteCachedFeedCallCount += 1
            deletionCompletions.append(completion)
            receivedMesages.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0 ) {
            deletionCompletions[index](nil)
        }
        
        func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            // insertCallCount += 1
            // insertions.append((items, timestamp))
            insertionCompletions.append(completion)
            receivedMesages.append(.insert(items, timestamp))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0 ) {
            insertionCompletions[index](nil)
        }
        
    }
}
