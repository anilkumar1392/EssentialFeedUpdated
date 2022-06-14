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
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

extension FeedPresenationTest {
    private class ViewSpy {
        var messages = [Any]()
    }
}
