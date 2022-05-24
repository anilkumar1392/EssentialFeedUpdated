//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 24/05/22.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
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
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        
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
        
        wait(for: [exp], timeout: 1.0)
    }
}
