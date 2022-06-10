//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/06/22.
//

import Foundation
import EssentialFeed
import UIKit

public protocol FeedImageDataTaskLoader {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataTaskLoader
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?

    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath: FeedImageDataTaskLoader]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader?) {
        self.init()
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            guard let self = self else { return }
            
            if let feed = try? result.get() {
                self.tableModel = feed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
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
