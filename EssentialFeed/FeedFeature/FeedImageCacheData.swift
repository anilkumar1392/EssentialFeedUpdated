//
//  FeedImageCacheData.swift
//  EssentialFeed
//
//  Created by 13401027 on 25/06/22.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
