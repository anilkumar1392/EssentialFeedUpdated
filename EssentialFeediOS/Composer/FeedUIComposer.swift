//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

import Foundation
import EssentialFeed

/*
 ### Adding MVVM
 
 Why?
  As our iOS ViewController depends directly on Core components like FeedImage and <FeedLoader>.
  Beacuse of that theri is lot of state management.
  All that state management Inflates the number of responsibility some controller have.
 
 */
public final class FeedUIComsposer {
    private init() { }
    
    public static func viewComopsedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader?) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: loader)
        let refreshController = FeedRefreshViewContoller(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        
        // refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader!)
        
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader!)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map({ feed in
                FeedImageCellController(model: feed, imageLoader: loader)
            })
        }
    }
}
