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
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversInstanceSavedOnSeparateInstances() {
        let sutToPerforSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        saveFeed(feed, sutToPerforSave)
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemSaveOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        
        saveFeed(firstFeed, sutToPerformFirstSave)
        saveFeed(latestFeed, sutToPerformLastSave)
        expect(sutToPerformLoad, toLoad: latestFeed)
        
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
    
    private func saveFeed(_ feed: [FeedImage], _ sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for first save to complete")
        sut.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected first to save successfully")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let loadExp = expectation(description: "wait for load operation to complete")
        sut.load { result in
            switch result {
            case let .success(feeds):
                XCTAssertEqual(feeds, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed results, got \(error) instead.", file: file, line: line)
            }
            
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
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
