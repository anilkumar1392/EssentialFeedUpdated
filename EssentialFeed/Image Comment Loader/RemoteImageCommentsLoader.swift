//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 18/07/22.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}


/*
public final class RemoteImageCommentsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion : @escaping (Result) -> Void ) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map(data: data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    static func map(data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
 */
