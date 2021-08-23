//
//  BurgerListControllerTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 9/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import UIKit

final class BurgerListViewController: UIViewController {
    private var loader: BurgerListControllerTests.LoaderSpy?
    
    convenience init(loader: BurgerListControllerTests.LoaderSpy) {
        self.init()
        
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

class BurgerListControllerTests: XCTestCase {
    
    func test_init_doesNotMesssageLoader() {
        let loader = LoaderSpy()
        _ = BurgerListViewController(loader: loader)
        
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadsBugerList() {
        let loader = LoaderSpy()
        let sut = BurgerListViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
    }
    
    // MARK: - Helpers
    class LoaderSpy {
        private(set) var loaderCallCount = 0
        
        func load() {
            loaderCallCount += 1
        }
    }
}
