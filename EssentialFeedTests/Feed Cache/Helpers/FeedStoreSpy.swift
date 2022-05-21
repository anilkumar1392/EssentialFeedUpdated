//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 21/05/22.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
 
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var retrivalCompletions = [InsertionCompletion]()
    // var deleteCachedFeedCallCount = 0
    // var insertCallCount = 0
    // var insertions = [(items: [FeedItem], timestamp: Date)]()
    
    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMesages = [ReceivedMessages]()
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        // deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
        receivedMesages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0 ) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        // insertCallCount += 1
        // insertions.append((items, timestamp))
        insertionCompletions.append(completion)
        receivedMesages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0 ) {
        insertionCompletions[index](nil)
    }

    func retrieve(completion: @escaping RetrivalCompletion) {
        retrivalCompletions.append(completion)
        receivedMesages.append(.retrieve)
    }
    
    func completeRetrival(with error: Error, at index: Int = 0) {
        retrivalCompletions[index](error)
    }
    
    func completeRetrivalWithEmptyCache(at index: Int = 0) {
        retrivalCompletions[index](nil)
    }
}
