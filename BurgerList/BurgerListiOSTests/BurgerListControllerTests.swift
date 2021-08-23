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

final class BurgerListViewController: UITableViewController {
    private var loader: BurgerLoader?
    
    convenience init(loader: BurgerLoader) {
        self.init()
        
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
        refresh()
    }
    
    @objc private func refresh() {
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

class BurgerListControllerTests: XCTestCase {
    
    func test_init_doesNotMesssageLoader() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadsBugerList() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
    }
    
    func test_userInitiatedReload_loadBurgeList() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loaderCallCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loaderCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isShowingLodingIndicator, true)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeBurgerLoading()
        
        XCTAssertEqual(sut.isShowingLodingIndicator, false)
    }
    
    func test_userInitiatedReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.isShowingLodingIndicator, true)
    }
    
    func test_userInitiatedReload_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedReload()
        loader.completeBurgerLoading()
        
        XCTAssertEqual(sut.isShowingLodingIndicator, false)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: BurgerListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = BurgerListViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, loader: loader)
    }
    
    class LoaderSpy: BurgerLoader {
        var loaderCallCount: Int {
            completions.count
        }
        private(set) var completions = [(BurgerLoader.Result) -> Void]()
        
        func load(completion: @escaping (BurgerLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeBurgerLoading() {
            completions[0](.success([]))
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
