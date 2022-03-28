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

final class BurgersPresenter {
    private let errorView: BurgerErrorView
    
    init(errorView: BurgerErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingBurgers() {
        errorView.display(.noError)
    }
}

class BurgerPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages on init, got \(view.messages) instead")
    }
    
    func test_didStatLoadingBurger_displauNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingBurgers()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: BurgersPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgersPresenter(errorView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class ViewSpy: BurgerErrorView {
        var messages = [Message]()
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        func display(_ viewModel: BurgerErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.errorMessage))
        }
    }
}
