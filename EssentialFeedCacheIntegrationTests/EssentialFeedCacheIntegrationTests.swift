//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by 13401027 on 02/06/22.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoDateOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(feeds):
                XCTAssertEqual(feeds, [], "Expected empty feeds")
                
            case let .failure(error):
                 XCTFail("Expected successfull feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let url = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: url, bundle: bundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
