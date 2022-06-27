//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 27/06/22.
//

import Foundation
import XCTest
import EssentialFeediOS

// Idea is to render the user interface and take the snapshot.

class FeedSnapshotsTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        let snapshot = sut.snapshot()
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
    func emptyFeed() -> [FeedImageCellController] {
        return []
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
