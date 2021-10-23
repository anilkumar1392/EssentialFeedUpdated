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

public protocol HTTPClient {
    func get(from url: URL?, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void ) {
        //1. HTTPClient.shared.requestedURL = URL(string: "https.goolge.com")
        //2. HTTPClient.shared.get(from: URL(string: "https.goolge.com"))
        client.get(from: url, completion: { error,response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        })
    }
}
