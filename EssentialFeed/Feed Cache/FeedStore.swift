//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
