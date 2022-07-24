//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 14/06/22.
//

import Foundation
import UIKit

public final class ErrorView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    public var message: String? {
        get { return isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate func hideMessage() {
        label.text = nil
        alpha = 0
    }
    
    private func configure() {
        backgroundColor = .errorBackgroundColor
        configureLabel()
        hideMessage()
    }

    private func configureLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
        ])
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        hideMessage()
    }

    private var isVisible: Bool {
        return alpha > 0
    }

    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        label.text = message

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @IBAction private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            })
    }
}


extension UIColor {
    static var errorBackgroundColor: UIColor {
        .red
    }
}
