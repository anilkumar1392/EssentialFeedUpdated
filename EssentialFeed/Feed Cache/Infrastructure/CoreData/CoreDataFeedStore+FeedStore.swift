//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by 13401027 on 22/06/22.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrivalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map({
                    CacheFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                })
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
            
            /*
            
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            } */
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
             })
            
            /*
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }*/
        }
    }
}
