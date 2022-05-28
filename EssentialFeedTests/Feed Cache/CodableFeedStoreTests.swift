//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 24/05/22.
//

import Foundation
import XCTest
import EssentialFeed

/*
 ### FeedStore implementation Inbox

 ### - Retrieve
     - Empty cache works (before something is inserted)
     - Retrieve empty cache twice returns empty (no side-effects)
     - Non-empty cache returns data
     - Non-empty cache twice returns same data (retrieve should have no side-effects)
     - Error returns error (if applicable to simulate, e.g., invalid data)
     - Error twice returns same error (if applicable to simulate, e.g., invalid data) (no side effects)
     
 ### Insert
     - To empty cache works
     - To non-empty cache overrides previous value
     - Error (if possible to simulate, e.g., no write permission)
     
 ### - Delete
     - Empty cache does nothing (cache stays empty and does not fail)
     - Inserted data leaves cache empty
     - Error (if possible to simulate, e.g., no write permission)

 ### - Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)

 */





/*
 if we run the test agiain after stroing the data once test will pass and after that test will fail.
 
 Cause: because of atrifacts, PREVIOUS TEST LEFT SOME DATA.
 
 So good Side of using omcking is tat is does not add artifcats or side effects in system.
 while side effects of using filesystem is it add artifacts. In may effect the ehole system.
 
 So we need to clean the disk avery time we run the disk.
 */

/*
 High level component should not depend on low level component.
 
 So changes we made like LocalFeedLoader confirm to codable is framework specific so in future we may need to add coredata specific or realm specific framework details.
 
 To rectify this we can have a local implementation of LocalFeedModel
 */


/*
 Designing and Testing Thread-safe Components with DispatchQueue, Serial vs. Concurrent Queues, Thread-safe Value Types, and Avoiding Race Conditions
 their are no direct dependency on Concrete infrastructure implementations
 */

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Get called every time after execution of each test.
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        // Get called every time after execution of each test.
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        /*
        let exp = expectation(description: "wait for exp for fullfill")
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
         */
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        /*
        let exp = expectation(description: "wait for exp for fullfill")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult)  {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected retriving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead.")
                }
                
                exp.fulfill()
            }
            
        }
        
        wait(for:  xp], timeout: 1.0) */
        
        /*
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
         */
        
        expect(sut, toRetrieveTwice: .empty)

    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        // test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues
        // Given
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        /*
        let exp = expectation(description: "wait for exp for fullfill")
        
        // Insert
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()

            /*
            sut.retrieve { retrieveResult in
                switch retrieveResult  {
                case let .found(feed: retrieveFeed, timestamp: retrieveTimestamp):
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrieveTimestamp, timestamp)

                default:
                    XCTFail("Expected found result with \(feed) and \(timestamp), got \(retrieveResult) instead.")
                }
                
                exp.fulfill()
            } */
        }
        wait(for: [exp], timeout: 1.0)
         */
        
        insert((feed, timestamp), to: sut)
        //Expect
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        /*
        let exp = expectation(description: "wait for exp for fullfill")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()

            /*
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult)  {
                    case let (.found(firstResult), .found(secondResult)):
                        XCTAssertEqual(firstResult.feed, feed)
                        XCTAssertEqual(firstResult.timestamp, timestamp)
                        
                        XCTAssertEqual(secondResult.feed, feed)
                        XCTAssertEqual(secondResult.timestamp, timestamp)

                    default:
                        XCTFail("Expected retriving twice from non empty cache to devliver same result with \(feed) adn \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                    exp.fulfill()
                }
            } */
        }
        
        wait(for: [exp], timeout: 1.0)
         */
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_returnsFailureOnInvalidData() {
        let storeURL = testsSpecificStoreUrl()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testsSpecificStoreUrl()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to store value in the cahce")
        
        let feed = uniqueImageFeed().local
        let date = Date()
        let secondInsertionError = insert((feed, date), to: sut)
        XCTAssertNil(secondInsertionError, "Expected to insert data to store")
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: date))
    }
    
    func test_insert_deliverErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invlid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviousInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let delectionError = deleteCache(sut)
        
        XCTAssertNil(delectionError, "Expected non-empty cache to delete successfully")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionUrl = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionUrl)
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    // Thread test make sure thread run serially.
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completeOperationsInOrder = [XCTestExpectation]()

        let feed = uniqueImageFeed().local
        let date = Date()
        
        let exp1 = expectation(description: "wait for insertion to complete")
        sut.insert(feed, timestamp: date) { _ in
            completeOperationsInOrder.append(exp1)
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "wait for deletion to complete")
        sut.deleteCachedFeed { _ in
            completeOperationsInOrder.append(exp2)
            exp2.fulfill()
        }
        
        let exp3 = expectation(description: "wait for insertion to complete")
        sut.insert(feed, timestamp: date) { _ in
            completeOperationsInOrder.append(exp3)
            exp3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completeOperationsInOrder, [exp1, exp2, exp3], "Expected order to finish inorder")
    }
}

// MARK: - Helpers

extension CodableFeedStoreTests {
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeUrl = storeURL ?? testsSpecificStoreUrl()
        let sut = CodableFeedStore(storeUrl: storeUrl)
        
        // Next is track memory leak
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        // Given
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        
        // When
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            // XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        
        // Expect
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    
    private func deleteCache(_ sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache to delete")
        var expectedError: Error?
        
        sut.deleteCachedFeed { receviedError in
            expectedError = receviedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return expectedError
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrival")
        
        sut.retrieve { retrieveResult in
            switch (retrieveResult, expectedResult)  {
            case let (.found(retrieveResult), .found(expectedResult)):
                XCTAssertEqual(retrieveResult.feed, expectedResult.feed, file: file, line: line)
                XCTAssertEqual(retrieveResult.timestamp, expectedResult.timestamp, file: file, line: line)
                
            case (.empty, .empty),
                (.failure, .failure):
                break

            default:
                XCTFail("Expecetd to retrieve \(expectedResult), got \(retrieveResult) Instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func setupEmptyStoreState() {
        removeStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        removeStoreArtifacts()
    }
    
    private func removeStoreArtifacts() {
        try? FileManager.default.removeItem(at: testsSpecificStoreUrl())
    }
    
    private func testsSpecificStoreUrl() -> URL {
        let url = cachesDirectory().appendingPathComponent("\(type(of: self)).store") // CodableFeedStoreTests
        return url
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    /*
     if sharing a url with other parts of the system it may have fragile tests, because they can be effected by un-related tests.
     Solution: so we can create a test specific url that is only used by these tests.
     So if their is a proble it is contained with in these test.
     */
}
