//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by 13401027 on 12/06/22.
//

import Foundation
import UIKit

extension UIButton {
    func simulateTap() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
