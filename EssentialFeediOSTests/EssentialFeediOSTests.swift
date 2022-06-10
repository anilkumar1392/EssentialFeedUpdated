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
        
        XCTAssertEqual(loader.loadFeedCallCount, 0)
    }
    
    // Load feed automatically when the view is presented
    // Allow customers to manually reload feed (Pull to refresh)
    
    func test_loadFeedAction_requestsFeedFromLoader() { // test_viewDidLoad_loadsFeed
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading requests once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading requests once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading requests once user initiates a load")
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
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 2)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Epxected no indicator once user initiated a loading finished")
    }
    
    /*
     While testing in collection test
     1. 0 case
     2. 1 item case
     2. multiple items case
     */
    func test_loadFeedCompletion_rendersSuccessfullyLoadedData() {
        let image0 = makeItem(description: "a description", location: "a location")
        let image1 = makeItem(description: nil, location: "another location")
        let image2 = makeItem(description: "another description", location: nil)
        let image3 = makeItem(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        //XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        assertThat(sut, isRendering: [])
        
        
        loader.completeFeedLoading(with: [image0], at: 0)
        //XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 1)
        assertThat(sut, isRendering: [image0])
        
        
        //        // Check if correct data is poupulated
        //        let view = sut.feedImageView(at: 0) as? FeedImageCell
        //        XCTAssertNotNil(view)
        //        XCTAssertEqual(view?.isShowingLocation, true)
        //        XCTAssertEqual(view?.locationText, image0.location)
        //        XCTAssertEqual(view?.descriptionText, image0.description)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        // XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 4)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
        
        //        assertThat(sut, hasViewConfiguredFor: image0, at: 0)
        //        assertThat(sut, hasViewConfiguredFor: image1, at: 1)
        //        assertThat(sut, hasViewConfiguredFor: image2, at: 2)
        //        assertThat(sut, hasViewConfiguredFor: image3, at: 3)
        
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError()  {
        let image0 = makeItem(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    // Load when ImageView is visible
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeItem(url: URL(string: "http://url-0.com")!)
        let image1 = makeItem(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image urls until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view become visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view become visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnyMore() {
        let image0 = makeItem(url: URL(string: "http://url-0.com")!)
        let image1 = makeItem(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancel image url until imageview is visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")

        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible any more")
    }
    
    
    // MARK: - Helper methods
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let feedLoader = LoaderSpy()
        // let imageLoader = LoaderSpy()

        let sut = FeedViewController(loader: feedLoader, imageLoader: feedLoader)
        trackForMemoryLeaks(feedLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, feedLoader)
    }
    
    private func makeItem(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
        
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) image, got \(sut.numberOfRenderedFeedImageViews()) image.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, feed in
            assertThat(sut, hasViewConfiguredFor: feed, at: index)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instacne, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected 'isShowingLocation' to be \(shouldLocationBeVisible) for image view at \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionLabel.text, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.locationLabel.text, image.location, "Expected description text to be \(String(describing: image.location)) for image view at index \(index)", file: file, line: line)
        
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        var loadFeedCallCount: Int  {
            return feedRequests.count
        }
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader

        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()

        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
        
        func cancelImageDataLoad(from url: URL) {
            cancelledImageURLs.append(url)
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
    
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }

    func simulateFeedImageViewNotVisible(at index: Int) {
        let view = simulateFeedImageViewVisible(at: index)
        
        let deleagte = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSection)
        deleagte?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    private var feedImageSection: Int {
        return 0
    }
}


extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}
