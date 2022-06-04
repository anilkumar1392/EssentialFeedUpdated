//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

//public enum CacheFeed {
//    case empty
//    case found(feed: [LocalFeedImage], timestamp: Date)
//}

//public struct CacheFeed {
//    public let feed: [LocalFeedImage]
//    public let timestamp: Date
//
//    public init(feed: [LocalFeedImage], timestamp: Date) {
//        self.feed = feed
//        self.timestamp = timestamp
//    }
//}

public typealias CacheFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CacheFeed?, Error>
    typealias RetrivalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch it to appropriate thread, if needed. 
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch it to appropriate thread, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch it to appropriate thread, if needed.
    func retrieve(completion: @escaping RetrivalCompletion)
}

/*
 It might seem that we are duplicating code
 but they may change due to different reasons
 
 We might have to add more properties to it
 
 so by seperating them we are allowing them to change at their own pace.
 
 ** this is first step towards centrialization.
 we can develop diff module in paraller without effecting each other.
 
 This technique is called DTO (Data transfer technique)
 So it is just a data transfer reperesentation of model to remove strong coupling.
 */
 
