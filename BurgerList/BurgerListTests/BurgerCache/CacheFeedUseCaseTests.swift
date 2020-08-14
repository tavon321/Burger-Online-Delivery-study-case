//
//  CacheFeedUseCaseTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 8/14/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest

class LocalBurgerLoader {
    private let store: BurgerStore
    
    init(store: BurgerStore) {
        self.store = store
    }
}

class BurgerStore {
    var deleteCachedBurgerCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = BurgerStore()
        _ = LocalBurgerLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedBurgerCallCount, 0)
    }

}
