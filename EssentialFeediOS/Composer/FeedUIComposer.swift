//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

import Foundation
import EssentialFeed

public final class FeedUIComsposer {
    private init() { }
    
    public static func viewComopsedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader?) -> FeedViewController {
        let refreshController = FeedRefreshViewContoller(feedLoader: loader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map({ feed in
                FeedImageCellController(model: feed, imageLoader: imageLoader!)
            })
        }
        
        return feedController
    }
}
