//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

import Foundation

public protocol FeedImageDataTaskLoader {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataTaskLoader
}
