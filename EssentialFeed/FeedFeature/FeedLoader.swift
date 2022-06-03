//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 10/10/21.
//

import Foundation

/*
public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

// extension LoadFeedResult: Equatable where Error: Equatable {}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
*/

//public enum LoadFeedResult {
//    case success([FeedImage])
//    case failure(Error)
//}

// public typealias LoadFeedResult = Result<[FeedImage], Error>
// extension LoadFeedResult: Equatable where Error: Equatable {}

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
