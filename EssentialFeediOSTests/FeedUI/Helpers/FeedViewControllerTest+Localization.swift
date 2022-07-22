//
//  FeedViewControllerTest+Localization.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 12/06/22.
//

import Foundation
import EssentialFeediOS
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
    
    private class DummyView: ResourceView {
        func display(viewModel: Any) { }
    }
    
    // DSL
    var loadError: String {
        // localized("GENERIC_CONNECTION_ERROR", table: "Shared")
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    /*
    func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table \(table))", file: file, line: line)
        }
        return value
    } */
}
