//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 12/06/22.
//

import Foundation
import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
