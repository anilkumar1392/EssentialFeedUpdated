//
//  ImageCommentsSnapshotsTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 24/07/22.
//

import Foundation
import XCTest
@testable import EssentialFeed
import EssentialFeediOS

class ImageCommentsSnapshotsTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(comments())

        // added robust test
        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func comments() -> [CellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales  in Bangor, Gwynedd, North Wales.",
                    date: "1000 years ago",
                    username: "a long long long username"
                )
            ),
            ImageCommentCellController(
                            model: ImageCommentViewModel(
                                message: "Garth Pier is a Grade II listed structure",
                                date: "10 days ago",
                                username: "a username"
                            )
            ),
            ImageCommentCellController(
                            model: ImageCommentViewModel(
                                message: "Garth",
                                date: "1 hour ago",
                                username: "a long long long username"
                            )
            )
        ]
    }
}
