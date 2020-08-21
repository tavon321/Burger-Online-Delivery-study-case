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
    private let currentDate: () -> Date
    
    init(store: BurgerStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [Burger]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class BurgerStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedBurgerCallCount = 0
    var insertions = [(items: [Burger], timestamp: Date)]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCachedBurgerCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [Burger], timestamp: Date = Date()) {
        insertions.append((items: items, timestamp: timestamp))
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
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestCacheInsertionWihtTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = createSUT(currentDate: { timestamp })
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
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
    
    private func createSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalBurgerLoader, store: BurgerStore) {
        let store = BurgerStore()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate )
        
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut: sut, store: store)
    }
}
