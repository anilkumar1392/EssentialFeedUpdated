//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 22/07/22.
//

import Foundation
import XCTest
import EssentialFeed

class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValueExist(in: bundle, table)
    }
    
    private class DummyView: ResourceView {
        func display(viewModel: String) { }
    }
}
