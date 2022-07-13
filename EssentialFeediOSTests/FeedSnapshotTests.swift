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

class FeedSnapshotsTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_feed_withContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }
}

extension FeedSnapshotsTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
}

extension FeedSnapshotsTests {
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }

    private func feedWithContent() -> [FeedImageCellController] {
        return [FeedImageCellController(viewModel:
                        FeedImageViewModel(model: FeedImage(id: UUID(), description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.", location: "East Side Gallery\nMemorial in Berlin, Germany", url: URL(string: "http://url.com")!),
                                           imageLoader: FeedImageLoader(),
                                           imageTransformer: UIImage.init)),
                FeedImageCellController(viewModel:
                                FeedImageViewModel(model: FeedImage(id: UUID(), description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.", location: "Garth Pier", url: URL(string: "http://another.com")!),
                                                   imageLoader: FeedImageLoader(),
                                                   imageTransformer: UIImage.init))]
    }

    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return
        }
        
        // ../EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to create snapshots with error: \(error)", file: file, line: line)
        }
        
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
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
        
                                   
