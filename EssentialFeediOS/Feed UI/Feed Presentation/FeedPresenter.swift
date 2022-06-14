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

struct FeedErrorViewModel {
    let message: String?
}

protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
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
    private var errorView: FeedErrorView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    init(feedView: FeedView, loadingView: FeedloadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        // errorView.display(viewModel: .)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.feedView.display(viewModel: FeedViewModal(feed: feed))
        self.loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(viewModel: FeedErrorViewModel(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
