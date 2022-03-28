//
//  BurgerPresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest

struct BurgerErrorViewModel {
    var errorMessage: String?
    
    static var noError: BurgerErrorViewModel {
        BurgerErrorViewModel(errorMessage: nil)
    }
}

protocol BurgerErrorView {
    func display(_ viewModel: BurgerErrorViewModel)
}

struct BurgerLoadingViewModel {
    var isLoading: Bool
}

protocol LoadingBurgerView: AnyObject {
    func display(_ viewModel: BurgerLoadingViewModel)
}

final class BurgersPresenter {
    private let errorView: BurgerErrorView
    private let loadingBurgerView: LoadingBurgerView
    
    init(errorView: BurgerErrorView, loadingBurgerView: LoadingBurgerView) {
        self.errorView = errorView
        self.loadingBurgerView = loadingBurgerView
    }
    
    func didStartLoadingBurgers() {
        loadingBurgerView.display(.init(isLoading: true))
        errorView.display(.noError)
    }
}

class BurgerPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages on init, got \(view.messages) instead")
    }
    
    func test_didStatLoadingBurger_displauNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingBurgers()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: BurgersPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgersPresenter(errorView: view, loadingBurgerView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class ViewSpy: BurgerErrorView, LoadingBurgerView {
        
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        func display(_ viewModel: BurgerErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.errorMessage))
        }
        
        func display(_ viewModel: BurgerLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
    }
}
