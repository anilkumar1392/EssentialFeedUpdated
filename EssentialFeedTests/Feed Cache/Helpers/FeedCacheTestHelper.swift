//
//  FeedCacheTestHelper.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 22/05/22.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let localItems = items.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    return (items, localItems)
}

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: nil, location: nil, url: anyUrl())
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyUrl(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

func makeItemJson(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}


// Break in to differant extensions because they belong to differnet context.

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private  func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
  
extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
