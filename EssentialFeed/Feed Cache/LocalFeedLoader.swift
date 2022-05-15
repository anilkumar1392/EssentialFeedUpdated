//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    /*
     Protecting our code from breaking changes
     */
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionerror = error {
                completion(cacheDeletionerror)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map( {LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}
