//
//  BurgerListControllerTests.swift
//  BurgerListiOSTests
//
//  Created by Gustavo on 9/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import UIKit
import BurgerList
import BurgerListiOS

class BurgerListControllerTests: XCTestCase {
    
    func test_loadBurgerActions_requestBurgerListFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loaderCallCount, 0, "Expected NO loading request when the view isn't loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loaderCallCount, 1, "Expected loading request when the view did load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loaderCallCount, 2, "Expected a request when the user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loaderCallCount, 3, "Expected a 2nd request when the user initiates a load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingBurgerList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLodingIndicator, true, "Expected loading indicator once the view is loaded")
        
        loader.completeBurgerLoading(at: 0)
        XCTAssertEqual(sut.isShowingLodingIndicator, false, "Expected no loading indicator once the view loading is completed")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLodingIndicator, true, "Expected loading indicator once the user initiates a refresh")
        
        loader.completeBurgerLoading(at: 1)
        XCTAssertEqual(sut.isShowingLodingIndicator, false, "Expected no loading indicater once user initiated refresh ended")
    }
    
    func test_loadBurgerListCompletion_renderCellView() {
        let burger0 = makeBurger(name: "a name", description: "a desccription")
        let burger1 = makeBurger(name: "a name")
        let burger2 = makeBurger(name: "a name", imageURL: anyURL)
        let burger3 = makeBurger(name: "a name", description: "a desccription", imageURL: anyURL)
        
        
        let (sut, loader) = makeSUT()
        
        assertThat(sut, isRendering: [])
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0])
        assertThat(sut, isRendering: [burger0])
        
        let burgers = [burger0, burger1, burger2, burger3]
        sut.simulateUserInitiatedReload()
        loader.completeBurgerLoading(with: burgers, at: 1)
        assertThat(sut, isRendering: burgers)
    }
    
    // MARK: - Helpers
    private func assertThat(_ sut: BurgerListViewController,
                            isRendering burgers: [Burger],
                            file: StaticString = #file,
                            line: UInt = #line) {
        guard sut.numberOfRenderedBurgerListViews() == burgers.count else {
            return XCTFail("Expected \(burgers.count), got \(sut.numberOfRenderedBurgerListViews()) instead",
                           file: file,
                           line: line)
        }
        
        burgers.enumerated()
            .forEach({ assert(sut, hasViewCofiguredFor: $1, at: $0,
                              file: file,
                              line: line) })
    }
    
    private func assert(_ sut: BurgerListViewController,
                        hasViewCofiguredFor burger: Burger,
                        at index: Int,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let view = sut.burgerImageView(at: index) as? BurgerCell
        
        XCTAssertNotNil(view,
                        "Expected \(BurgerCell.self) instance, got \(String(describing: view)) instead",
                        file: file,
                        line: line)
        
        let burgerDescription = burger.description != nil
        XCTAssertEqual(view?.isShowingDescription, burgerDescription,
                       "Expected 'isShowingDescription' to be \(burgerDescription) on burger\(index)",
                       file: file,
                       line: line)
        
        XCTAssertEqual(view?.descriptionText, burger.description,
                       "Expected 'descriptionText' to be \(String(describing: burger.description)), got \(String(describing: view?.descriptionText))",
                       file: file,
                       line: line)
        
        XCTAssertEqual(view?.nameText, burger.name,
                       "Expected 'nameText' to be \(burger.name), got \(String(describing: view?.nameText))",
                       file: file,
                       line: line)
    }
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: BurgerListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BurgerListViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, loader: loader)
    }
    
    private func makeBurger(name: String,
                            description: String? = nil,
                            imageURL: URL? = nil)
    -> Burger {
        Burger(id: UUID(), name: name, description: description, imageURL: imageURL)
    }
    
    class LoaderSpy: BurgerLoader {
        var loaderCallCount: Int {
            completions.count
        }
        private(set) var completions = [(BurgerLoader.Result) -> Void]()
        
        func load(completion: @escaping (BurgerLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeBurgerLoading(with burgers: [Burger] = [], at index: Int = 0) {
            completions[index](.success(burgers))
        }
    }
}

private extension BurgerListViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLodingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func numberOfRenderedBurgerListViews() -> Int {
        tableView.numberOfRows(inSection: burgerImageSection)
    }
    
    func burgerImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: burgerImageSection)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var burgerImageSection: Int { 0 }
}

private extension BurgerCell {
    var isShowingDescription: Bool {
        !descriptionLabel.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var nameText: String? {
        nameLabel.text
    }
}
private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}
