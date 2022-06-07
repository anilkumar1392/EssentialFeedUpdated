//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 07/06/22.
//

import Foundation
import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc func load() {
        loader?.load { _ in }
    }
}

class FeeedViewControllerTests: XCTestCase {
    
    // Just by init we dont want loader to load anything
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // Load feed automatically when the view is presented
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // Allow customers to manually reload feed (Pull to refresh)
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showLoadingInidcator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    // MARK: - Helper methods
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount: Int = 0

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent:
                    .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
