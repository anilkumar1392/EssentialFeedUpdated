//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 21/06/22.
//

import Foundation
import XCTest
import EssentialFeed

//public protocol FeedImageDataTaskLoader {
//    func cancel()
//}
//
//public protocol FeedImageDataLoader {
//    typealias Result = Swift.Result<Data, Error>
//    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataTaskLoader
//}

class LocalFeedImageDataLoader {
    
    // let store: FeedStoreSpy
    
    init(store: Any) {
        // self.store = store
    }
    
//    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTaskLoader {
//    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (sut, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
        
    }
}

// MARK: - Helepr methods

extension LocalFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
}

extension LocalFeedImageDataLoaderTests {
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}
