//
//  UIImageView+Animation.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 12/06/22.
//

import Foundation
import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
