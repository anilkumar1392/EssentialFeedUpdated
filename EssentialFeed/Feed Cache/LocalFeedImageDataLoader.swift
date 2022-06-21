//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 21/06/22.
//

import Foundation

public class LocalFeedImageDataLoader: FeedImageDataLoader {
    private final class Task: FeedImageDataTaskLoader {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTaskLoader {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            /*
            completion(result
                .mapError { _ in Error.failed }
                .flatMap { _ in .failure(Error.notFound) }) */
            
            /*
            completion(result
                .mapError { _ in Error.failed }
                .flatMap { data in data.map { .success($0)} ?? .failure(Error.notFound) }) */
            
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(Error.notFound)
                })
        }
        return task
    }
}
