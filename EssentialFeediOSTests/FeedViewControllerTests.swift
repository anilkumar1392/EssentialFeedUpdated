//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 07/06/22.
//

import Foundation
import XCTest

class FeedViewController {
    init(loader: FeeedViewControllerTests.LoaderSpy) {
        
    }
}
class FeeedViewControllerTests: XCTestCase {
    
    // Just by init we dont want loader to load anything
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    // MARK: - Helper methods
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
