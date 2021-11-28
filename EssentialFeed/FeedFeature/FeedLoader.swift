//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 10/10/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(compltion: @escaping (LoadFeedResult<Error>) -> Void)
}
