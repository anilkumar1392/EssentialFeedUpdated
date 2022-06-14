//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

import Foundation
import EssentialFeed
import UIKit

/*
 ### Adding MVVM
 
 Why?
  As our iOS ViewController depends directly on Core components like FeedImage and <FeedLoader>.
  Beacuse of that theri is lot of state management.
  All that state management Inflates the number of responsibility some controller have.
 
 */

/*
public final class FeedUIComsposer {
    private init() { }
    
    public static func viewComopsedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader?) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: loader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        
        // refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader!)
        
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader!)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map({ feed in
                // FeedImageCellController(model: feed, imageLoader: loader)
                FeedImageCellController(viewModel: FeedImageViewModel(model: feed, imageLoader: loader, imageTransformer: UIImage.init))
            })
        }
    }
}
*/

/*
 MVVM
 */

/*
public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let title = NSLocalizedString("FEED_VIEW_TITLE",
                                      tableName: "Feed",
                                      bundle: Bundle(for: FeedUIComposer.self),
                                      comment: "Title for the feed view")
        let feedViewModel = FeedViewModel(
            feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader),
            title: title)
        // let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        
         let feedController = FeedViewController(refreshController: refreshController)
         let bundle = Bundle(for: FeedViewController.self)
         let storyBoard = UIStoryboard(name: "Feed", bundle: bundle)
         let feedController = storyBoard.instantiateInitialViewController() as! FeedViewController
        
        let feedController = FeedViewController.makeWith()
        
        let feedRefreshController = feedController.refreshController
        feedRefreshController?.viewModel = feedViewModel
        
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(
            forwardingTo: feedController,
            loader: MainQueueDispatchDecorator(decoratee: imageLoader))
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel:
                    FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
            }
        }
    }
}

private extension FeedViewController {
    static func makeWith() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyBoard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        return feedController
    }
}
*/

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let title = NSLocalizedString("FEED_VIEW_TITLE",
                                      tableName: "Feed",
                                      bundle: Bundle(for: FeedUIComposer.self),
                                      comment: "Title for the feed view")

        // let feedPresenter = FeedPresenter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader), title: title)
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        // let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        // let refreshController = FeedRefreshViewController(delegate: presentationAdapter)

        // let feedController = FeedViewController(refreshController: refreshController)
        // feedController.refreshController = refreshController
        
        // let refreshController = feedController.refreshController!
        // refreshController.delegate = presentationAdapter

        let feedController = FeedViewController.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        let feedPresenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader),
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController)
            )
        presentationAdapter.presenter = feedPresenter
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyBoard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyBoard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}


// weakify object in composer

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init (_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedloadingView where T: FeedloadingView  {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView  {
    func display(viewModel: FeedErrorViewModel) {
        object?.display(viewModel: viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private var imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedViewModal) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(viewModel:
                FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {

    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case .failure(let error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
