//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by 13401027 on 23/10/21.
//

import Foundation

/*
 In production code we do not want to set aa proprety but we want to call a method to get data from Url.
 
 1. Move the test logic from Remote loader to HttpCLient
 2. We don't want requestedUrl as this is just for testing not in production so Let's move this to a different class by making HttpClient a var.
 3. Move the test logic to a new class HttpClientSpy subclass of HTTPClient
 */


/*
 Above we are mixing the responsiblity
 1. Responsibility of Invoking the get method.
 2. Responsibility of locating this shared object.
 
 /*
  By using Singleton I know how to locate the instance I'm using and I dont need to konw.
  So by using Dependency Injection we can remove this responsibilty and we ahve more control.
  */
 
*/

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL?, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void ) {
        //1. HTTPClient.shared.requestedURL = URL(string: "https.goolge.com")
        //2. HTTPClient.shared.get(from: URL(string: "https.goolge.com"))
        client.get(from: url, completion: { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemMapper.mapper(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
                /*
                if let items = try? FeedItemMapper.mapper(data, response){
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }*/
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

private class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
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
    
    static func mapper(_ data: Data,_ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}


