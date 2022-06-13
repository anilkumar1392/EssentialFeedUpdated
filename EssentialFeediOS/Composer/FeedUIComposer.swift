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
        
        // let feedController = FeedViewController(refreshController: refreshController)
        // let bundle = Bundle(for: FeedViewController.self)
        // let storyBoard = UIStoryboard(name: "Feed", bundle: bundle)
        // let feedController = storyBoard.instantiateInitialViewController() as! FeedViewController
        
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

/*
 
   1.  Add behaviour to an instance wthout while keeping the same interface
   Following Open and close principle.
   Adding behaviour without changing the insatacne.
 
   So the ViewModel does not know about threading, Controller does not know about threading.
 
 */

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}
   
extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTaskLoader {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
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
