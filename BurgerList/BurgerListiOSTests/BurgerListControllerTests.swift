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
        
        refresh()
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

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
        
        func completeBurgerLoading(at index: Int) {
            completions[index](.success([]))
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
