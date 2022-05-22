//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 22/05/22.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "Any error", code: 0)
}

func anyUrl() -> URL {
    return  URL(string: "https://any-url.com")!
}
