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
    
    func save() {
        store.deleteCachedBurgerCallCount += 1
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
    
    func test_save_requestCacheDeletion() {
        let store = BurgerStore()
        let sut = LocalBurgerLoader(store: store)
        
        sut.save()
        
        XCTAssertEqual(store.deleteCachedBurgerCallCount, 1)
    }

}
