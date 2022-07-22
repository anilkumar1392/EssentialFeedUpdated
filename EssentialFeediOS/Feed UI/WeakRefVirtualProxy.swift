//
//  WeakRefVirtualProxy.swift
//  EssentialApp
//
//  Created by 13401027 on 26/06/22.
//

import Foundation
import EssentialFeediOS
import EssentialFeed

// weakify object in composer

public final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init (_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView  {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView  {
    public func display(viewModel: FeedErrorViewModel) {
        object?.display(viewModel: viewModel)
    }
}
