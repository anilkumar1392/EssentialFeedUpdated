//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by 13401027 on 14/06/22.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    public static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
