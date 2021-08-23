//
//  BurgerListControllerTests.swift
//  BurgerListTests
//
//  Created by Gustavo on 9/08/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import UIKit
import BurgerList

final class BurgerListViewController: UIViewController {
    private var loader: BurgerLoader?
    
    convenience init(loader: BurgerLoader) {
        self.init()
        
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
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
    class LoaderSpy: BurgerLoader {
        private(set) var loaderCallCount = 0
        
        func load(completion: @escaping (BurgerLoader.Result) -> Void) {
            loaderCallCount += 1
        }
    }
}
