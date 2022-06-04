//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by 13401027 on 02/06/22.
//

import XCTest 
import EssentialFeed

/*
 So if you test edge cases in unit test In integration you can only test happy path.
 We need to test only happy path as we have already written test for sad path in Unit tests.
 With number of items in collobation the number of test cases will grow exponentially.
 In Integration test we can not mock
 We can not force an error at integration level but We can mock an error on unit level.
 
 On Integration level we are using real components.
 
 As integraiton test are very slow and if we move all possiblel cases to integration test, tests become unmaintainable number of test and very slow test times.
 
 We need both unit and Integration test.
 But huge majority should be unit test.
 
 Test all the edge cases in unit test.
 Then integrate all the componenet and see all how they behave together.
 
 */

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
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected first to save successfully", file: file, line: line)
            }
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
