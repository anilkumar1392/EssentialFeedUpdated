//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/06/22.
//

import Foundation
import EssentialFeed
import UIKit

/*
 
 Clean code and separate responsibility are must but not enough.
 We mist manage dependancy smartly.
 we need to move the depandency creation and injection to a separate component.
  
 */

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedloadingView, FeedErrorView {

    // private var imageLoader: FeedImageDataLoader?
    
    // var refreshController: FeedRefreshViewController?
    // @IBOutlet var refreshController: FeedRefreshViewController?

//    private var tableModel = [FeedImage]() {
//        didSet {
//            self.tableView.reloadData()
//        }
//    }
    // private var cellControllers = [IndexPath: FeedImageCellController]()
    
    @IBOutlet private(set) public var errorView: ErrorView?

    var delegate: FeedViewControllerDelegate?

    var tableModel = [FeedImageCellController]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // refreshControl = refreshController?.view
        /*
        title = refreshController?.viewModel?.getTitle()
        refreshController?.bindView()
        refreshController?.refresh() */

        // tableView.tableHeaderView = errorView
        refresh()
    }
    
    @IBAction private func refresh() {
        // presenter.loadFeed()
        // loadFeed()
        self.delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ viewModel: FeedLoadingViewModel) {
        guard Thread.isMainThread else {
            return  DispatchQueue.main.async { [weak view] in
                self.refreshControl?.update(isRefreshing: viewModel.isLoading)
            }
        }
        refreshControl?.update(isRefreshing: viewModel.isLoading)

    }
    
    public func display(viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
//    convenience init(refreshController: FeedRefreshViewController?) {
//        self.init()
//        self.refreshController = refreshController
//    }
    
    /*
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader?) {
        self.init()
        // FeedRefreshViewContoller needs loader we can direclty inject FeedRefreshViewContoller instead of creating it.
        self.refreshController = FeedRefreshViewContoller(feedLoader: loader)
        // self.imageLoader = imageLoader
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed.map({ feed in
                FeedImageCellController(model: feed, imageLoader: imageLoader!)
            })
        }
    } */
    
    /*
    public convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    } */
    

}

extension FeedViewController {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view(in: tableView)
    }
    
    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        canCancelCellControllerLoad(forRowAt: indexPath)
        
        // removeCellController(forRowAt: indexPath)
 
        /*
         /// responsibility is moved to cell controller
         // cancelTask(forRowAt: indexPath)
         */
        
        // tasks[indexPath]?.cancel()
        // tasks[indexPath] = nil
        /*
        let cellModel = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: cellModel.url) */
        
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            /*
            let cellModel = tableModel[indexPath.row]
            _ = imageLoader?.loadImageData(from: cellModel.url, completion: { _ in })
            */
            
            _ = cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(canCancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        // FeedImageCellController need imageLaoder viewController needs loader, we care creatig it instead we can inject FeedRefreshViewContoller instead of creating it.

        /*
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController */
        
        return tableModel[indexPath.row]
    }
    
    private func canCancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        
        cellController(forRowAt: indexPath).cancelLoad()
        
        // cellControllers[indexPath] = nil
        
        /*
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil */
    }
}
