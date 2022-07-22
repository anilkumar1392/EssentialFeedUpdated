//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by 13401027 on 22/07/22.
//

import Foundation

public protocol ResourceView {
    func display(viewModel: String)
}

public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    private var resourceView: ResourceView
    private var errorView: FeedErrorView
    private var loadingView: FeedloadingView
    private var mapper: Mapper

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(resourceView: ResourceView, errorView: FeedErrorView, loadingView: FeedloadingView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    public func didStartLoading() {
        errorView.display(viewModel: .noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: String) {
        resourceView.display(viewModel: mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(viewModel: .error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
