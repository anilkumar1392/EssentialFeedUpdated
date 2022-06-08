//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 07/06/22.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

/*
 When their is temporla coupling involved it is benfiricaery to merge similar tests.
 
 Like sequence to view Life cycle methods.
 
 But still separate them in logical unit.
 Like for refresh control tests are in on function.
 */


class FeeedViewControllerTests: XCTestCase {
    
    // Just by init we dont want loader to load anything
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // Load feed automatically when the view is presented
    // Allow customers to manually reload feed (Pull to refresh)

    func test_loadFeedAction_requestsFeedFromLoader() { // test_viewDidLoad_loadsFeed
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading requests once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading requests once user initiates a load")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading requests once user initiates a load")
    }

    // Show loading indicator while loading feed
    func test_loadingFeedIndicatorIsVisible_whileLoadingFeed() { // test_viewDidLoad_showLoadingInidcator
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Epxected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Epxected no indicator once loading is finished")
        
        sut.simulateUserInitiatedFeedReload()
        // XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Epxected indicator indicator once user initiates a loading")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Epxected no indicator once user initiated a loading finished")
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
        var loadCallCount: Int  {
            return messages.count
        }
        
        private var messages = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            messages.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            messages[index](.success([]))
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

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
}


