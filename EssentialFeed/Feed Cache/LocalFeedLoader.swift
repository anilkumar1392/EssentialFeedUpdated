//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

/*
 Extract the bussiness rule into its own module and resue it later if we have to.
 */

/*
 Feed cache policy is impure because every time you invoke this function this may return a different value, its non deterministic.
 One way to make it pure is by using data instead of data in init.
 */

/*
 A business model are separated into models that have identity and ohter have no identity.
 1. like a customer that can be identiyfied and other like a policy that can not be identified. (like a rule)
 
 (Business rule with identity) = entity, we sepearte them by entity: entity are models that have identity.
 value objects are model with no identity.
 Policy has no identity. (so its a value type)
 
 */

private final class FeedCachePolicy {
    /*
     so FeedCachePolicy has no identity, and holds no state.
     So we do not need a instacne.
     we can directly use static.
     */
    // private let currentDate: () -> Date
    
    private init() {}
    private static let calender = Calendar(identifier: .gregorian)
    
//    public init(currentDate: @escaping () -> Date) {
//        self.currentDate = currentDate
//    }
    
    static var maxCacheAgeInDays: Int {
        return 7
    }
    
    public static func validate(_ timestamp: Date, against  date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    // private let calender = Calendar(identifier: .gregorian)
    // private let cachePolicy = FeedCachePolicy()
    
    /*
     Protecting our code from breaking changes
     */
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
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

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                // self.store.deleteCachedFeed { _ in }
                completion(.failure(error))
                
            case let .found(feed: localFeedImage, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(localFeedImage.toModels()))
                
            case .found, .empty:
                // self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp: timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
                
            case .empty, .found: break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map( {LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels () -> [FeedImage] {
        return map( {FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}
