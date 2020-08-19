//
//  CacheFeedUseCaseTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 8/14/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
@testable import BurgerList

class LocalBurgerLoader {
    private let store: BurgerStore
    
    init(store: BurgerStore) {
        self.store = store
    }
    
    func save(_ items: [Burger]) {
        store.deleteCachedBurgerCallCount += 1
    }
}

class BurgerStore {
    var deleteCachedBurgerCallCount = 0
    var insertCallCount = 0
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = createSUT()
            
        XCTAssertEqual(store.deleteCachedBurgerCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = createSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedBurgerCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = createSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items)
        
        store.completeDeletion(with: anyError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // MARK: - Helpers
    private var uniqueItem: Burger {
        return Burger(id: UUID(), name: "a name", description: "a description", imageURL: anyURL)
    }
    
    private var anyURL: URL {
        return URL(string: "http://any-url.com")!
    }
    
    var anyError: NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func createSUT() -> (sut: LocalBurgerLoader, store: BurgerStore) {
        let store = BurgerStore()
        let sut = LocalBurgerLoader(store: store)
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, store: store)
    }
}
