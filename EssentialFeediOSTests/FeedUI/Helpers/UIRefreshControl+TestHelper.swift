//
//  UIRefreshControl+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 12/06/22.
//

import Foundation
import UIKit

public extension UIRefreshControl {
    public func simulatePullToRefresh() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
