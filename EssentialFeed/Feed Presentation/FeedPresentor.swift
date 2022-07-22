//
//  FeedPresentor.swift
//  EssentialFeed
//
//  Created by 13401027 on 14/06/22.
//

public protocol FeedView {
    func display(viewModel: FeedViewModal)
}

public class FeedPresenter {
    private var feedView: FeedView
    private var errorView: ResourceErrorView
    private var loadingView: ResourceLoadingView

    static public var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(feedView: FeedView, errorView: ResourceErrorView, loadingView: ResourceLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    // data in -> created view models -> Data out to the UI
    
    // Void -> created view model -> sends to the UI
    public func didStartLoadingFeed() {
        errorView.display(viewModel: .noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    // [FeedImage] -> created view model -> sends to the UI
    // [ImageComment] -> created view model -> sends to the UI
    // Resource -> created ResourceViewModel -> sends to the UI

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: Self.map(feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    // Error -> created view model -> sends to the UI
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(viewModel: .error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModal {
        FeedViewModal(feed: feed)
    }
}
