//
//  FeedRefreshViewContoller.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

import Foundation
import EssentialFeed
import UIKit

public class FeedRefreshViewContoller: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            
            if let feed = try? result.get() {
                self.onRefresh?(feed)
            }
            self.view.endRefreshing()
        }
    }
}
