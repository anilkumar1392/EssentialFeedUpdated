//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 14/06/22.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
