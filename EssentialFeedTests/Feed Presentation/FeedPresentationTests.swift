//
//  FeedPresentationTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 14/06/22.
//

import Foundation
import XCTest

class FeedPresenter {
    
    init(view: Any) {
    }
}

class FeedPresenationTest: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (sut, view) = makeSUT()
 
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
}

extension FeedPresenationTest {
    private class ViewSpy {
        var messages = [Any]()
    }
}
