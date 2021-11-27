//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by 13401027 on 27/11/21.
//

import Foundation

class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, image: image)
        }
    }
    
    private static var OK_200: Int {
        return 200
    }
    
    static func mapper(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
