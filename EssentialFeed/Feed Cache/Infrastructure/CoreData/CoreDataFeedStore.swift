//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by 13401027 on 29/05/22.
//

import Foundation
import CoreData

/*
 In coreData data model leaves in main production bundle.
 Which is differnect than the test bundle.
 So it is essential we choose the correct bundle.
 So we injected the bundle when testing in production.
 
 Pointing the store at /dev/null
 The null device discards all data directed to it while reporting that write operations succeeded.

 By using a file URL of /dev/null for the persistent store, the Core Data stack will not save SQLite artifacts to disk, doing the work in memory. This means that this option is faster when running tests, as opposed to performing I/O and actually writing/reading from disk. Moreover, when operating in-memory, you prevent cross test side-effects since this process doesn’t create any artifacts.
 
 */

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping RetrivalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map({
                    return CacheFeed(feed: $0.localFeed, timestamp: $0.timestamp)
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

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}


