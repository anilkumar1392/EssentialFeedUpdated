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
 
 /// Searating Application specific logic from concrete framework details. (like coredata, realm)
 So feedStore protocol protects our controller from depending on concrete store implemenation like (Coradata, realm, file system)
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
