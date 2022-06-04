//
//  XCTestCase+FailableDeleteFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 28/05/22.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
