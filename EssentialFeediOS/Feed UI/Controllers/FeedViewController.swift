//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/06/22.
//

import Foundation
import EssentialFeed
import UIKit

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageDataLoader?
    private var tasks = [IndexPath: FeedImageDataTaskLoader]()
    
    private var refreshController: FeedRefreshViewContoller?
    private var tableModel = [FeedImage]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader?) {
        self.init()
        self.refreshController = FeedRefreshViewContoller(feedLoader: loader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
}

extension FeedViewController {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url, completion: { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
                cell?.feedImageRetryButton.isHidden = (image != nil)
            })
        }
        
        cell.onRetry = loadImage
        loadImage()
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
        // tasks[indexPath]?.cancel()
        // tasks[indexPath] = nil
        /*
        let cellModel = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: cellModel.url) */
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            _ = imageLoader?.loadImageData(from: cellModel.url, completion: { _ in
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
