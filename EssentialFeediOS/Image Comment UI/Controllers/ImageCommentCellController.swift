//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 24/07/22.
//

import Foundation
import UIKit
import EssentialFeed

public final class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        UITableViewCell()
    }
    
    public func preload() {
        
    }
    
    public func cancelLoad() {
        
    }    
}
