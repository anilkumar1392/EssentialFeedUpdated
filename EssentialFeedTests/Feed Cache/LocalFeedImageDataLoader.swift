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

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataTaskLoader {
        func cancel() { }
    }
    
    public enum Error: Swift.Error {
        case failed
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTaskLoader {
        store.retrieve(dataForURL: url) { result in
            completion(.failure(Error.failed))
        }
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestStoreDataFromURL() {
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: anyUrl()) { result in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: anyUrl())])
    }
}

// MARK: - Helepr methods

extension LocalFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
}

extension LocalFeedImageDataLoaderTests {
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}
