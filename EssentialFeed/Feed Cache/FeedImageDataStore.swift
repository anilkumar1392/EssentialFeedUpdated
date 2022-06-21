//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by 13401027 on 21/06/22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
