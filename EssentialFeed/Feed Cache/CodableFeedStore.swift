//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by 13401027 on 27/05/22.
//

import Foundation

/*
 Low level framework implementation.
 Framework must work according to this expections
 
 ### FeedStore implementation Inbox

 ### - Retrieve
     - Empty cache works (before something is inserted)
     - Retrieve empty cache twice returns empty (no side-effects)
     - Non-empty cache returns data
     - Non-empty cache twice returns same data (retrieve should have no side-effects)
     - Error returns error (if applicable to simulate, e.g., invalid data)
     - Error twice returns same error (if applicable to simulate, e.g., invalid data) (no side effects)
     
 ### Insert
     - To empty cache works
     - To non-empty cache overrides previous value
     - Error (if possible to simulate, e.g., no write permission)
     
 ### - Delete
     - Empty cache does nothing (cache stays empty and does not fail)
     - Inserted data leaves cache empty
     - Error (if possible to simulate, e.g., no write permission)

 ### - Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)

 */

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedModel] // LocalFeedImage
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableFeedModel: Codable {
        private var id: UUID
        private var description: String?
        private var location: String?
        private var url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.description
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        let storeUrl = self.storeUrl
        queue.async {
            guard let data = try? Data(contentsOf: storeUrl) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }

    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let storeUrl = self.storeUrl

        queue.async {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(Cache(feed: feed.map (CodableFeedModel.init), timestamp: timestamp))
                try encoded.write(to: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        let storeUrl = self.storeUrl

        queue.async {
            guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(atPath: storeUrl.path)
                completion(nil)
            } catch {
                completion(error)
            }
            
        }
    }
}
