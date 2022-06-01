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


typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

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
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
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
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        // test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues
        // Given
        let sut = makeSUT()
        
        /*
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "wait for exp for fullfill")
        
        // Insert
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()

            sut.retrieve { retrieveResult in
                switch retrieveResult  {
                case let .found(feed: retrieveFeed, timestamp: retrieveTimestamp):
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrieveTimestamp, timestamp)

                default:
                    XCTFail("Expected found result with \(feed) and \(timestamp), got \(retrieveResult) instead.")
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
         */
        
        // insert((feed, timestamp), to: sut)

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)

    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
        
//        let feed = uniqueImageFeed().local
//        let timestamp = Date()
        
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
        
        //insert((feed, timestamp), to: sut)
        // expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))

    }
    
    func test_retrieve_returnsFailureOnRetrivalError() {
        let storeURL = testsSpecificStoreUrl()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
        
        // expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testsSpecificStoreUrl()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)

        // expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
        /*
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully") */
         
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
        
        /*
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to override cache successfully")
         */
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
        
        /*
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to store value in the cahce")
        
        let feed = uniqueImageFeed().local
        let date = Date()
        let secondInsertionError = insert((feed, date), to: sut)
        XCTAssertNil(secondInsertionError, "Expected to insert data to store")
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: date))
         */
    }
    
    func test_insert_deliverErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invlid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
        
        /*
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
         */
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invlid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
        
        /*
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .empty)
         */
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let error = deleteCache(sut)
        
        XCTAssertNil(error, "Expected deletion to complete successfully")
    }
    

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
        
        /*
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty) */
    }
    
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let error = deleteCache(sut)
        
        XCTAssertNil(error, "Expected deletion to complete successfully")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
        
        /*
        let delectionError = deleteCache(sut)
        
        XCTAssertNil(delectionError, "Expected non-empty cache to delete successfully")
        expect(sut, toRetrieve: .empty) */
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionUrl = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionUrl)
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)

        /*
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
         */
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
        let noDeletePermissionUrl = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionUrl)
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)

        /*
        deleteCache(sut)
        
        expect(sut, toRetrieve: .empty) */
    }
    
    // Thread test make sure thread run serially.
    /// Side effect must run serially to avoid race condition
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatSideEffectsRunSerially(on: sut)
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
