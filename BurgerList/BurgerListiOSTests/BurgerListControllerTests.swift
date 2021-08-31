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
        
        XCTAssertEqual(loader.burgerRequestCallCount, 0, "Expected NO loading request when the view isn't loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.burgerRequestCallCount, 1, "Expected loading request when the view did load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.burgerRequestCallCount, 2, "Expected a request when the user initiates a load")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.burgerRequestCallCount, 3, "Expected a 2nd request when the user initiates a load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingBurgerList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLodingIndicator, true, "Expected loading indicator once the view is loaded")
        
        loader.completeBurgerLoading(at: 0)
        XCTAssertEqual(sut.isShowingLodingIndicator, false, "Expected no loading indicator once the view loading is completed successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLodingIndicator, true, "Expected loading indicator once the user initiates a refresh")
        
        loader.completeBurgerLoading(with: anyError, at: 1)
        XCTAssertEqual(sut.isShowingLodingIndicator, false, "Expected no loading indicater once user initiated refresh ended with error")
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
    
    func test_loadBurgerCompletion_doesNotAlterCurrentRenderingState() {
        let burger0 = makeBurger(name: "a name", description: "a desccription")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0])
        assertThat(sut, isRendering: [burger0])
        
        sut.simulateUserInitiatedReload()
        loader.completeBurgerLoading(with: anyError)
        assertThat(sut, isRendering: [burger0])
    }
    
    func test_burgerView_loadsImageURLWhenVisible() {
        let burger0 = makeBurger(name: "a name", imageURL: URL(string:"http://url-0.com")!)
        let burger1 = makeBurger(name: "a name", imageURL: URL(string:"http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0, burger1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expecte no image URL reques until views became visible")
        
        sut.simulateBurgerViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL],
                       "Expected first image URL Requested once the view is visible")
        
        sut.simulateBurgerViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [burger0.imageURL, burger1.imageURL],
                       "Expected first and second image URL Requested once the view is visible")
    }
    
    func test_burgerView_cancelsLoadsImageURLWhenNotVisible() {
        let burger0 = makeBurger(name: "a name", imageURL: URL(string:"http://url-0.com")!)
        let burger1 = makeBurger(name: "a name", imageURL: URL(string:"http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading(with: [burger0, burger1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expecte no cancelled image URL until the image is not visible")
        
        sut.simulateBurgerViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [burger0.imageURL],
                       "Expected one image to be cancelled once the image is not visible")
        
        sut.simulateBurgerViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [burger0.imageURL, burger1.imageURL],
                       "Expected all the images to be cancelled once the second image is not visiblle")
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
        let view = sut.burgerImageView(at: index)
        
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
        let sut = BurgerListViewController(burgerLoader: loader, imageLoader: loader)
        
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
    
    class LoaderSpy: BurgerLoader, BurgerImageLoader {
        
        private(set) var burgerRequest = [(BurgerLoader.Result) -> Void]()
        
        var burgerRequestCallCount: Int {
            burgerRequest.count
        }
        
        // MARK: BurgerLoader
        func load(completion: @escaping (BurgerLoader.Result) -> Void) {
            burgerRequest.append(completion)
        }
        
        func completeBurgerLoading(with burgers: [Burger] = [], at index: Int = 0) {
            burgerRequest[index](.success(burgers))
        }
        
        func completeBurgerLoading(with error: Error, at index: Int = 0) {
            burgerRequest[index](.failure(error))
        }
        
        // MARK: BurgerImageLoader
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
        
        func cancelImageDataLoad(from url: URL) {
            cancelledImageURLs.append(url)
        }
    }
}

private extension BurgerListViewController {
    
    @discardableResult
    func simulateBurgerViewVisible(at index: Int) -> BurgerCell? {
        return burgerImageView(at: index)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateBurgerViewNotVisible(at row: Int) {
        guard let view = simulateBurgerViewVisible(at: row) else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: burgerImageSection)
        
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: index)
    }
    
    var isShowingLodingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func numberOfRenderedBurgerListViews() -> Int {
        tableView.numberOfRows(inSection: burgerImageSection)
    }
    
    func burgerImageView(at row: Int) -> BurgerCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: burgerImageSection)
        
        return ds?.tableView(tableView, cellForRowAt: index) as? BurgerCell
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
