//
//  FeedPresentor.swift
//  EssentialFeed
//
//  Created by 13401027 on 14/06/22.
//

public protocol FeedView {
    func display(viewModel: FeedViewModal)
}

public protocol FeedloadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}

public class FeedPresenter {
    private var feedView: FeedView
    private var errorView: FeedErrorView
    private var loadingView: FeedloadingView

    static public var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(feedView: FeedView, errorView: FeedErrorView, loadingView: FeedloadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    // data in -> created view models -> Data out to the UI
    
    // Void -> created view model -> sends to the UI
    public func didStartLoadingFeed() {
        errorView.display(viewModel: .noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    // [FeedImage] -> created view model -> sends to the UI
    // [ImageComment] -> created view model -> sends to the UI
    // Resource -> created ResourceViewModel -> sends to the UI

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModal(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    // Error -> created view model -> sends to the UI
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(viewModel: .error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
