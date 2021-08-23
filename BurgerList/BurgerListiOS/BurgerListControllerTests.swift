//
//  BurgerListControllerTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 9/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest

final class BurgerListViewController {
    init(loader: LoaderSpy) {
    }
}

class BurgerListControllerTests: XCTest {
    
    func test_init_doesNotMesssageLoader() {
        let loader = LoaderSpy()
        _ = BurgerListViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    class LoaderSpy {
        private(set) var loaderCallCount = 0
    }
}
