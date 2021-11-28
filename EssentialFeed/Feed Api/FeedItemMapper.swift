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
        var feed: [FeedItem] {
            return items.map({ $0.item })
        }
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
    
    /*
    static func mapper(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }*/
    
    static func map(data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
