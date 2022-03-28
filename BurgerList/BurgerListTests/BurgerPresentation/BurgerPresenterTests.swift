//
//  BurgerPresenterTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class BurgerPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(BurgersPresenter.title, localized("BURGERLIST_VIEW_TITLE"))
    }
    
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
    
    func test_didFinishLoadingBurgersWithError_displayLocalizedErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingBurgers(with: anyError)
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("BURGER_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
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
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Burgers"
        let bundle = Bundle(for: BurgersPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
