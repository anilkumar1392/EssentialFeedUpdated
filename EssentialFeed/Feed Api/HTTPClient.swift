//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by 13401027 on 27/11/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
