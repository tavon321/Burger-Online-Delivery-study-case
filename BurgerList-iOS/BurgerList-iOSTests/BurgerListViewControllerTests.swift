//
//  BurgerListViewControllerTests.swift
//  BurgerList-iOSTests
//
//  Created by Gustavo on 6/08/21.
//

import XCTest
@testable import BurgerList_iOS

class BurgerListViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = BurgerListViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    class LoaderSpy: BurgerLoader {
        private(set) var loadCallCount = 0
    }
}
