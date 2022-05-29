//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 29/05/22.
//

import Foundation
import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
//        let sut = makeSUT()
//
//        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
   func test_storeSideEffects_runSerially() {
//        let sut = makeSUT()
//        var completeOperationsInOrder = [XCTestExpectation]()
//
//        let feed = uniqueImageFeed().local
//        let date = Date()
//
//        let exp1 = expectation(description: "wait for insertion to complete")
//        sut.insert(feed, timestamp: date) { _ in
//            completeOperationsInOrder.append(exp1)
//            exp1.fulfill()
//        }
//
//        let exp2 = expectation(description: "wait for deletion to complete")
//        sut.deleteCachedFeed { _ in
//            completeOperationsInOrder.append(exp2)
//            exp2.fulfill()
//        }
//
//        let exp3 = expectation(description: "wait for insertion to complete")
//        sut.insert(feed, timestamp: date) { _ in
//            completeOperationsInOrder.append(exp3)
//            exp3.fulfill()
//        }
//
//        waitForExpectations(timeout: 5.0)
//        XCTAssertEqual(completeOperationsInOrder, [exp1, exp2, exp3], "Expected order to finish inorder")
    }
  
}

// MARK: - Helper methods

/*
 "dev/null" is a technique to direct the CoreData  ouptput to the null device.
 'null' device discards all the data that written to it, but reports that the writ eoperation succeeded.
 */

extension CoreDataFeedStoreTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

