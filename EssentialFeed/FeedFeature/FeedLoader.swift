//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 10/10/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
