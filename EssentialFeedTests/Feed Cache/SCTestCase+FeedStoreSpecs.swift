//
//  SCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 28/05/22.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
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
    
    
    func deleteCache(_ sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache to delete")
        var expectedError: Error?
        
        sut.deleteCachedFeed { receviedError in
            expectedError = receviedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return expectedError
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
        
        wait(for: [exp], timeout: 4.0)
        
    }
    
}
