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
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadsBugerList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
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
        private(set) var loaderCallCount = 0
        
        func load(completion: @escaping (BurgerLoader.Result) -> Void) {
            loaderCallCount += 1
        }
    }
}
