//
//  CacheFeedUseCaseTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 8/14/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
@testable import BurgerList

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = createSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = createSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(uniqueItems().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = createSUT()
        let items = uniqueItems().models
        
        sut.save(items) { _ in }
        
        store.completeDeletion(with: anyError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestCacheInsertionWihtTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = createSUT(currentDate: { timestamp })
        let items = uniqueItems()
        
        sut.save(items.models) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.localItems, timestamp)])
    }
    
    func test_save_failsDeletionError() {
        let (sut, store) = createSUT()
        let deletionError = anyError
        
        expect(sut: sut, toCompleteWith: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsInsertionError() {
        let (sut, store) = createSUT()
        let insertionError = anyError
        
        expect(sut: sut, toCompleteWith: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSucessfulInsertion() {
        let (sut, store) = createSUT()
        
        expect(sut: sut, toCompleteWith: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = BurgerStoreSpy()
        var sut: LocalBurgerLoader? = LocalBurgerLoader(store: store, currentDate: Date.init)
        
        var capturedError: Error?
        sut?.save(uniqueItems().models, completion: { error in
            capturedError = error
        })
        
        sut = nil
        store.completeDeletion(with: anyError)
        
        XCTAssertNil(capturedError)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = BurgerStoreSpy()
        var sut: LocalBurgerLoader? = LocalBurgerLoader(store: store, currentDate: Date.init)
        
        var capturedError: Error?
        sut?.save([uniqueItem], completion: { error in
            capturedError = error
        })
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyError)
        
        XCTAssertNil(capturedError)
    }
    
    // MARK: - Helpers
    private func expect(sut: LocalBurgerLoader,
                        toCompleteWith error: NSError?,
                        file: StaticString = #file,
                        line: UInt = #line,
                        when action: () -> Void) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(uniqueItems().models) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    private class BurgerStoreSpy: BurgerStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        
        private (set) var receivedMessages = [ReceivedMessage]()
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([LocalBurger], Date)
        }
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        func deleteCacheFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            
            receivedMessages.append(.deleteCachedFeed)
        }
        
        func insert(_ items: [LocalBurger], timestamp: Date = Date(), completion: @escaping (Error?) -> Void) {
            receivedMessages.append(.insert(items, timestamp))
            insertionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
    }
    
    private var uniqueItem: Burger {
        return Burger(id: UUID(), name: "a name", description: "a description", imageURL: anyURL)
    }
    
    private func uniqueItems() -> (models: [Burger], localItems: [LocalBurger]) {
        let items = [uniqueItem, uniqueItem]
        let localItems = items.map { LocalBurger(id: $0.id, name: $0.name, description: $0.description, imageURL: $0.imageURL) }
        
        return (models: items, localItems: localItems)
    }
    
    private var anyURL: URL {
        return URL(string: "http://any-url.com")!
    }
    
    var anyError: NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func createSUT(currentDate: @escaping () -> Date = Date.init,
                           file: StaticString = #file,
                           line: UInt = #line) -> (sut: LocalBurgerLoader, store: BurgerStoreSpy) {
        let store = BurgerStoreSpy()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, store: store)
    }
}
