//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by 13401027 on 23/07/22.
//

import Foundation

public final class ImageCommentsPresenter {
    static public var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the Image Comments view")
    }
}
