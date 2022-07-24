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

//public protocol FeedViewControllerDelegate {
//    func didRequestFeedRefresh()
//}

// Gettgin rid of this protocol and using closure.

/*
public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}

public extension CellController {
    func preload() {}
    func cancelLoad() {}
}
 */

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {

    private var loadingController = [IndexPath: CellController]()
    
    // private var imageLoader: FeedImageDataLoader?
    
    // var refreshController: FeedRefreshViewController?
    // @IBOutlet var refreshController: FeedRefreshViewController?

//    private var tableModel = [FeedImage]() {
//        didSet {
//            self.tableView.reloadData()
//        }
//    }
    // private var cellControllers = [IndexPath: FeedImageCellController]()
    
    private(set) public var errorView = ErrorView()

    public var onRefresh: (() -> Void)?

    private var tableModel = [CellController]() {
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
        
        configureErrorView()
        refresh()
    }
    
    func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
        
        tableView.tableHeaderView = container
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    @IBAction private func refresh() {
        // presenter.loadFeed()
        // loadFeed()
        // self.delegate?.didRequestFeedRefresh()
        
        onRefresh?()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public func display(_ cellController: [CellController]) {
        // Every time we get a new model to display we reset it.
        loadingController = [:]
        tableModel = cellController
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        guard Thread.isMainThread else {
            return  DispatchQueue.main.async { [weak view] in
                self.refreshControl?.update(isRefreshing: viewModel.isLoading)
            }
        }
        refreshControl?.update(isRefreshing: viewModel.isLoading)

    }
    
    public func display(viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
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

extension ListViewController {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view(in: tableView) */
        
        /*
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath) */
        
        let ds = cellController(forRowAt: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
        let controller = removeLoadingController(forRowAt: indexPath)
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath) */
        
        let dl = removeLoadingController(forRowAt: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        // canCancelCellControllerLoad(forRowAt: indexPath)
        
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
            
            // cellController(forRowAt: indexPath).preload()
            
            let dsp = cellController(forRowAt: indexPath).dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // indexPaths.forEach(canCancelCellControllerLoad)
        
        indexPaths.forEach { indexPath in
            let dsp = removeLoadingController(forRowAt: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        // FeedImageCellController need imageLaoder viewController needs loader, we care creatig it instead we can inject FeedRefreshViewContoller instead of creating it.

        /*
        let cellModel = tableModel[indexPath.row]
        let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController */
        
        let controller = tableModel[indexPath.row]
        loadingController[indexPath] = controller
        return controller
    }
    
    //canCancelCellControllerLoad
    private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingController[indexPath]
        loadingController[indexPath] = nil
        return controller

        /*
        loadingController[indexPath]?.cancelLoad()
        loadingController[indexPath] = nil
         */
        
        // cellController(forRowAt: indexPath).cancelLoad()
        
        // cellControllers[indexPath] = nil
        
        /*
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil */
    }
}
