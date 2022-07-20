//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 20/07/22.
//

import Foundation

public final class RemoteLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion : @escaping (Result) -> Void ) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteLoader.map(data: data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    static func map(data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data: data, from: response)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
