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
    func insertItems(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
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
 
public struct LocalFeedItem: Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = image
    }
}
