//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 10/10/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(compltion: @escaping (LoadFeedResult) -> Void)
}
