//
//  BurgerPresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

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

struct BurgerViewModel {
    var burgers: [Burger]
}

protocol BurgerView {
    func display(_ viewModel: BurgerViewModel)
}

final class BurgersPresenter {
    private let burgersView: BurgerView
    private let errorView: BurgerErrorView
    private let loadingBurgerView: LoadingBurgerView
    
    init(burgersView: BurgerView, errorView: BurgerErrorView, loadingBurgerView: LoadingBurgerView) {
        self.burgersView = burgersView
        self.errorView = errorView
        self.loadingBurgerView = loadingBurgerView
    }
    
    func didStartLoadingBurgers() {
        loadingBurgerView.display(.init(isLoading: true))
        errorView.display(.noError)
    }
    
    func didFinishLoadingBurgers(with burgers: [Burger]) {
        loadingBurgerView.display(.init(isLoading: false))
        burgersView.display(.init(burgers: burgers))
    }
}

class BurgerPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages on init, got \(view.messages) instead")
    }
    
    func test_didStatLoadingBurger_displayNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingBurgers()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingBurgers_displayBurgersAndStopsLoading() {
        let (sut, view) = makeSUT()
        let expectedBurgers = uniqueBurgers().models
        
        sut.didFinishLoadingBurgers(with: expectedBurgers)
        
        XCTAssertEqual(view.messages, [.display(burgers: expectedBurgers), .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: BurgersPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = BurgersPresenter(burgersView: view, errorView: view, loadingBurgerView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, view: view)
    }
    
    private class ViewSpy: BurgerView, BurgerErrorView, LoadingBurgerView {
        private(set) var messages = Set<Message>()
        
        enum Message: Hashable {
            case display(burgers: [Burger])
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        func display(_ viewModel: BurgerErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.errorMessage))
        }
        
        func display(_ viewModel: BurgerLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: BurgerViewModel) {
            messages.insert(.display(burgers: viewModel.burgers))
        }
    }
}
