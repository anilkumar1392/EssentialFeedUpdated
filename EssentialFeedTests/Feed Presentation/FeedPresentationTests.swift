//
//  FeedPresentationTests.swift
//  EssentialFeedTests
//
//  Created by 13401027 on 14/06/22.
//

import Foundation
import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedloadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}

class FeedPresenter {
    private var errorView: FeedErrorView
    private var loadingView: FeedloadingView

    init(errorView: FeedErrorView, loadingView: FeedloadingView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(viewModel: .noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

class FeedPresenationTest: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (sut, view) = makeSUT()
 
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view, loadingView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
}

extension FeedPresenationTest {
    private class ViewSpy: FeedErrorView, FeedloadingView {
        
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
    }
}
