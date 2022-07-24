//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 27/06/22.
//

import Foundation
import XCTest
import EssentialFeediOS
import EssentialFeed

// Idea is to render the user interface and take the snapshot.

// So first record the image.
// Second assert that the recorded Image matches the saved Image.

/*
 Because just recording the snapshot will just override the recorded snapshot.
 after we record it and we are happy with the result we
 need to assert the rendering against the recorded snapshot.
 */

// Assert function does not override the stored snapshot it just asserts.

// Avoid testing logic with snapshot tests.

/*
   Current implementation is very simple we can also make it more robust like check on specific iPhone device with light and dark mode.
 */

class FeedSnapshotsTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        // assert(snapshot: sut.snapshot(), named: "EMPTY_FEED")
        
        // added robust test
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
    }
    
    func test_feed_withContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        // assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_dark_extraExtraExtraLarge")

    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(viewModel: .error(message: "An error message"))
        
        // assert(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_dark")
    }
    
//    func test_feedWithFailedImageLoading() {
//        let sut = makeSUT()
//
//        sut.display(feedWithFailedImageLoading())
//
//        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
//    }
}

extension FeedSnapshotsTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
}

extension FeedSnapshotsTests {
    private func emptyFeed() -> [CellController] {
        return []
    }
    
    private func feedWithContent() -> [CellController] {
        feedControllers().map { CellController($0)}
    }

    private func feedControllers() -> [FeedImageCellController] {
        return [FeedImageCellController(viewModel:
                        FeedImageViewModel(model: FeedImage(id: UUID(), description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.", location: "East Side Gallery\nMemorial in Berlin, Germany", url: URL(string: "http://url.com")!),
                                           imageLoader: FeedImageLoader(),
                                           imageTransformer: UIImage.init)),
                FeedImageCellController(viewModel:
                                FeedImageViewModel(model: FeedImage(id: UUID(), description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.", location: "Garth Pier", url: URL(string: "http://another.com")!),
                                                   imageLoader: FeedImageLoader(),
                                                   imageTransformer: UIImage.init))]
    }
}

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone8(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: contentSize),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 2),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

private class FeedImageLoader: FeedImageDataLoader {
    struct TaskLoader: FeedImageDataTaskLoader {
        func cancel() { }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataTaskLoader {
        completion(.success(UIImage.make(withColor: .red).pngData() ?? Data()))
        return TaskLoader()
    }
}
        
                                   