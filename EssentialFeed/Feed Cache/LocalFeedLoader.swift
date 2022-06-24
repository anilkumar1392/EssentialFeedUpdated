//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

/*
 Presistance Module:
 Separating App-specific, App-agnostic & Framework logic, Entities vs. Value Objects, Establishing Single Sources of Truth, and Designing Side-effect-free (Deterministic) Domain Models with Functional Core, Imperative Shell Principles
 
 Independent modules with clear inetfaces.
 
 ///We separate application sepcific details from bussiness rules.

 we separate application specific details from bussines rules.
 Contollers are not business models, they communicate with business model to solve application specific business rules.
 
 Seperating bussiness model, controller and framework is a key to achieve modularity.
 To achieve freedom, to achieve freedom and testibility.
 
 You dictate your architecture not the framework will dictate your architecture.
 You plugin the framework to solve infraStructure details.
 
 /// Separating Application specific logic from concrete framework details. (like coredata, realm)
 So feedStore protocol protects our controller from depending on concrete store implemenation like (Coradata, realm, file system)
 */

/*
 we are writing test case to load data from cache
 
 1. So first case is over creati̧on it should not call store
 2. when we load we want a cache retrival from the store
 
 when we request a cache retrival couple fo things can happen
 1. it can fail
 2. We can get expired cache
 3. we can get empty cahce
 
 1. Devliers images when cache is less than seven days old
 2. Delviers no images on seven days old cache
 
 1. Delete cache on retrival error
 2. Should not delete the cache on empty cache
 
 ###Load Feed From Cache Use Case

 #### Primary course:
 1. Execute "Load Image Feed" command with above data.
 2. System fetchesretrieves feed data from cache.
 3. System validates cache is less than seven days old.
 4. System creates image feed from cached data.
 5. System delivers image feed.

 #### Retrieval Error course (sad path):
 1. System deletes cache.
 2. System delivers error.

 #### Expired cache course (sad path):
 1. System deletes cache.
 2. System delivers no feed images.

 #### Empty cache course (sad path):
 1. System delivers no feed images.
 
 Command–Query Separation Principle:  So seperate quering from command with side effects
 
 Seperating loading from validating:
 
 because this is volating Command-Query principle.
 we are fetcing and validating at same place.

 */

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

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.Result

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success():
                self.cache(feed, with: completion)

            case .failure(let cacheDeletionError):
                completion(.failure(cacheDeletionError))
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
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                // self.store.deleteCachedFeed { _ in }
                completion(.failure(error))
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))

            case .success:
                // self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                // self.store.deleteCachedFeed { _ in completion(.success(())) }
                self.store.deleteCachedFeed(completion: completion)

            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                // self.store.deleteCachedFeed { _ in completion(.success(())) }
                self.store.deleteCachedFeed(completion: completion)

            case .success:
                completion(.success(()))
            }
        }
    }
}
    
/*
extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
                
            case .success: break
            }
        }
    }
}
*/

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
