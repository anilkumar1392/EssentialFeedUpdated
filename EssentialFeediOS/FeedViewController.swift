//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by 13401027 on 08/06/22.
//

import Foundation
import EssentialFeed
import UIKit

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            
            self.tableModel = (try? result.get()) ?? []
            self.tableView.reloadData()
        }
    }
}

extension FeedViewController {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        return cell
    }
}
