//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 20/06/22.
//

import Foundation
import XCTest

class RemoteFeedImageDataLoader {
    var requestedUrl = [URL]()
    
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.requestedUrl.isEmpty)
    }
}

// MARK: - RemoteFeedImageDataLoaderTests

extension RemoteFeedImageDataLoaderTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> RemoteFeedImageDataLoader {
        let sut = RemoteFeedImageDataLoader()
        trackForMemoryLeaks(sut)
        return sut
    }
}
