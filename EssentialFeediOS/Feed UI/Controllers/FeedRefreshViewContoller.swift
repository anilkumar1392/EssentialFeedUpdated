//
//  FeedRefreshViewContoller.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 10/06/22.
//

// import EssentialFeed
import UIKit

/*
 Goal is to decouple FeedRefreshViewContoller from EssentialFeed core components
 */


/*
 Two common ways of creating ViewModel statefull and stateless.
 */

/*
 
 // MVVM
public class FeedRefreshViewController: NSObject {
    // private(set) lazy var view = binded(UIRefreshControl())
    @IBOutlet private var view: UIRefreshControl?

    
    //    private let feedLoader: FeedLoader
    //
    //    init(feedLoader: FeedLoader) {
    //        self.feedLoader = feedLoader
    //    }
    
//    private let viewModel: FeedViewModel
      var viewModel: FeedViewModel?

//    init(viewModel: FeedViewModel) {
//        self.viewModel = viewModel
//    }
    
    // var onRefresh: (([FeedImage]) -> Void)?
    
    //    @objc func refresh() {
    //        view.beginRefreshing()
    //        feedLoader.load { [weak self] result in
    //            guard let self = self else { return }
    //
    //            if let feed = try? result.get() {
    //                self.onRefresh?(feed)
    //            }
    //            self.view.endRefreshing()
    //        }
    //    }
    
    func bindView() {
        if let view = view {
            _ = binded(view)
        }
    }
    
    @IBAction func refresh() {
        viewModel?.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel?.onLoadingStateChange = { [weak view] isLoading in

            guard Thread.isMainThread else {
                return  DispatchQueue.main.async { [weak view] in
                    if isLoading {
                        view?.beginRefreshing()
                    } else {
                        view?.endRefreshing()
                    }
                }
            }
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
            
            //            if let feed = viewModel.feed {
            //                self.onRefresh?(feed)
            //            }
        }
        // view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
*/

protocol FeedRefereshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class FeedRefreshViewController: NSObject, FeedloadingView {

    // @IBOutlet private var view = loadView()
    private(set) lazy var view = loadView()

    // private let presenter: FeedPresenter
    
    // private let loadFeed: () -> Void

    /*
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    } */
    
    /*
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    } */
    
    var delegate: FeedRefereshViewControllerDelegate
    
    init(delegate: FeedRefereshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func refresh() {
        // presenter.loadFeed()
        // loadFeed()
        self.delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        guard Thread.isMainThread else {
            return  DispatchQueue.main.async { [weak view] in
                if viewModel.isLoading {
                    view?.beginRefreshing()
                } else {
                    view?.endRefreshing()
                }
            }
        }
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
