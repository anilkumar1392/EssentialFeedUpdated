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

  // 1. Does not delete cache upon creation.
  // 2. Save Request cache deletion.


class CacheFeedUseCaseTests: XCTestCase {
    
    /*
     We gererally use code base with tests that a method must call but
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

        sut.save(uniqueImageFeed().models) { _ in }
        
         // XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        XCTAssertEqual(store.receivedMesages, [.deleteCachedFeed])

    }
    
    // Deleting something may fail so.
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()

        sut.save(uniqueImageFeed().models) { _ in }
        
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

        let items = uniqueImageFeed()
        sut.save(items.models) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMesages, [.deleteCachedFeed, .insert(items.local, timestamp)])

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

        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
    
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
    
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    // MARK: - Helper methods
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expecetdError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for save completion")
        var receivedError: Error?

        sut.save(uniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 2.0)

        XCTAssertEqual(receivedError as NSError?, expecetdError)
    }
}
