//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/02/22.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal var id: UUID
    internal var description: String?
    internal var location: String?
    internal var image: URL
}
