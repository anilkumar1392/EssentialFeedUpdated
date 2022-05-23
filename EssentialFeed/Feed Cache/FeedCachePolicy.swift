//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by 13401027 on 23/05/22.
//

import Foundation

/*
 Extract the bussiness rule into its own module and resue it later if we have to.
 */

/*
 Feed cache policy is impure because every time you invoke this function this may return a different value, its non deterministic.
 One way to make it pure is by using data instead of data in init.
 */

/*
 A business model are separated into models that have identity and ohter have no identity.
 1. like a customer that can be identiyfied and other like a policy that can not be identified. (like a rule)
 
 (Business rule with identity) = entity, we sepearte them by entity: entity are models that have identity.
 value objects are model with no identity.
 Policy has no identity. (so its a value type)
 
 */

// we can make class as struct since require  no identity and shared state
internal final class FeedCachePolicy {
    
     /*
     so FeedCachePolicy has no identity, and holds no state.
     So we do not need a instacne.
     we can directly use static.
     */
    // private let currentDate: () -> Date
    private init() {}
    private static let calender = Calendar(identifier: .gregorian)
    
//    public init(currentDate: @escaping () -> Date) {
//        self.currentDate = currentDate
//    }
    
    static var maxCacheAgeInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against  date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
