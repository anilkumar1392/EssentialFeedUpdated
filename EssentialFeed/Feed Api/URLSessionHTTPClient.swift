//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by 13401027 on 08/01/22.
//

import Foundation


public class URLSessionHTTPClient: HTTPClient {

    let session: URLSession //HTTPSession //URLSession
    
    public init(session: URLSession = .shared) { // HTTPSession
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentaiton: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data , response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentaiton()))
            }
        }.resume()
    }
}
