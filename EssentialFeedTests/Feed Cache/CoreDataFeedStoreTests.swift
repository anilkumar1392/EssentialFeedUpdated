//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 29/05/22.
//

import Foundation
import XCTest

class CoreDataFeedStoreTests: XCTestCase, FailableFeedStore {
    func test_retrieve_returnsFailureOnRetrivalError() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        
    }
    
    func test_insert_deliverErrorOnInsertionError() {
        
    }
    
    func test_insert_hasNoSideEffectOnInsertionError() {
        
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
    }
    
    func test_delete_emptiesPreviousInsertedCache() {
    }
    
    func test_storeSideEffects_runSerially() {
    }
}
