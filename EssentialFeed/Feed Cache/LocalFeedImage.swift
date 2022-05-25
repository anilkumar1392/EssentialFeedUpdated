//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

/*
 Data transfer model representations for achieving modularity.
 Decentralizing components to develop and deploy parts of the system in parallel.
 
 A unified model can be a good starting solution, but it is often not scalable or cost-effective.

 A conformist approach and a decentralized approach would be more beneficial.
 It is essential to have more options to be able to identify when to switch strategies and refactor the design towards independence/freedom from external actors.
 
 
 */

public struct LocalFeedImage: Equatable, Codable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
