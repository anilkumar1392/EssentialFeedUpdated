//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 11/06/22.
//

import Foundation
import EssentialFeed

/*
 All the state mamanegemnt leaves in FeedViewModel a platform agnostic component.
 */

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    /*
    private enum State {
        case pending
        case loading
    }
    
    private var state: State = .pending {
        didSet { self.onChange?(self) }
    } */
    

    // var onChange: ((FeedViewModel) -> Void)?
    var onLoadingStateChange: Observer<Bool>? // ((Bool) -> Void)?
    var onFeedLoad: Observer<[FeedImage]>? //(([FeedImage]) -> Void)?
    
    /*
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    } */
    
    /*
    var isLoading: Bool {
        switch state {
        case .loading: return true
        default: return false
        }
    } */
    
    func loadFeed() {
        //isLoading = true
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }

            if let feed = try? result.get() {
                self.onFeedLoad?(feed)
            }
            // self.isLoading = false
            self.onLoadingStateChange?(false)
        }
    }
}
