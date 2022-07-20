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
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data , response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentaiton()
                }
            })

        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
