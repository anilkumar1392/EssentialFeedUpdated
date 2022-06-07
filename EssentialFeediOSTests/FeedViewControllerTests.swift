//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 07/06/22.
//

import Foundation
import XCTest
import UIKit

class FeedViewController: UIViewController {
    var loader: FeeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.loadView()
    }
}

class FeeedViewControllerTests: XCTestCase {
    
    // Just by init we dont want loader to load anything
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let vc = FeedViewController(loader: loader)

        vc.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helper methods
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func loadView() {
            loadCallCount += 1
        }
    }
}
