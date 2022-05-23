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



extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
