//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

import Foundation
import UIKit
import EssentialFeed


public class FeedImageCellController: NSObject {
    /*
    private var task: FeedImageDataTaskLoader?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
     */
    
    private let viewModel: FeedImageViewModel<UIImage>
    private var cell: FeedImageCell?
    
    public init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
}

extension FeedImageCellController: CellController {
    private func binded() {
        viewModel.onImageLoad = { [weak cell] image in
            DispatchQueue.main.async {
                cell?.feedImageView.setImageAnimated(image)
            }
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoadingCompleted in
            if isLoadingCompleted {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
    }
    
//    public func preload() {
//        viewModel.loadImageData()
//        // task = imageLoader.loadImageData(from: model.url, completion: { _ in })
//    }
    
    public func cancelLoad() {
        releaseCellForReuse()
        viewModel.cancelImageDataLoad()
        // task?.cancel()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
    /*
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageContainer.startShimmering()
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImageData(from: self.model.url, completion: { [weak cell] result in
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
    } */
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.image = nil
        cell?.feedImageRetryButton.isHidden = true
        cell?.feedImageContainer.startShimmering()
        cell?.onRetry = viewModel.loadImageData
        viewModel.loadImageData()
        binded()
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        viewModel.loadImageData()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
}


