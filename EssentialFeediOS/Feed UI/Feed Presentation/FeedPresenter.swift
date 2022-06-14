//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 14/06/22.
//

import Foundation
import EssentialFeed

// MVP presenter has a ref to view thorugh abstarct protocol

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedloadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModal {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewModal)
}

/*
 We can reovem twoway communication between presenter and  view by using adapter in between.
 
 Writing adapter code in compositon.
 */

/*
final class FeedPresenter {
    private let feedLoader: FeedLoader
    private let title: String
    var feedView: FeedView?
    var loadingView: FeedloadingView?

    init(feedLoader: FeedLoader, title: String) {
        self.feedLoader = feedLoader
        self.title = title
    }
    
    func getTitle() -> String {
        return title
    }

    func loadFeed() {
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            guard let self = self else { return }

            if let feed = try? result.get() {
                self.feedView?.display(viewModel: FeedViewModal(feed: feed))
            }
            self.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
} */

final class FeedPresenter {
    private var feedView: FeedView
    private var loadingView: FeedloadingView
    
    static var title: String {
        return "My Feed"
    }
    
    init(feedView: FeedView, loadingView: FeedloadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModal(feed: feed))
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
