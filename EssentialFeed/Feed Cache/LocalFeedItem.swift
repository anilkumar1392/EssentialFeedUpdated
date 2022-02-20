//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

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
