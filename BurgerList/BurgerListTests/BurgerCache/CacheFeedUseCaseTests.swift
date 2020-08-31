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
    
    func save(_ items: [Burger], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class BurgerStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    private (set) var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([Burger], Date)
    }
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        
        receivedMessages.append(.deleteCachedFeed)
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
    
    func insert(_ items: [Burger], timestamp: Date = Date(), completion: @escaping (Error?) -> Void) {
        receivedMessages.append(.insert(items, timestamp))
        insertionCompletions.append(completion)
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = createSUT()
            
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = createSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = createSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items) { _ in }
        
        store.completeDeletion(with: anyError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestCacheInsertionWihtTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = createSUT(currentDate: { timestamp })
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsDeletionError() {
        let (sut, store) = createSUT()
        let items = [uniqueItem, uniqueItem]
        let expectedError = anyError
        let exp = expectation(description: "Wait for save error in completion")
        
        sut.save(items) { receivedError in
            XCTAssertEqual(expectedError, receivedError as NSError?)
            exp.fulfill()
        }
        
        store.completeDeletion(with: expectedError)
        
        wait(for: [exp], timeout: 0.1)
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
    
    // MARK: - Helpers
    private func expect(sut: LocalBurgerLoader,
                        toCompleteWith error: NSError?,
                        file: StaticString = #file,
                        line: UInt = #line,
                        when action: () -> Void) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save([uniqueItem, uniqueItem]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    private var uniqueItem: Burger {
        return Burger(id: UUID(), name: "a name", description: "a description", imageURL: anyURL)
    }
    
    private var anyURL: URL {
        return URL(string: "http://any-url.com")!
    }
    
    var anyError: NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func createSUT(currentDate: @escaping () -> Date = Date.init,
                           file: StaticString = #file,
                           line: UInt = #line) -> (sut: LocalBurgerLoader, store: BurgerStore) {
        let store = BurgerStore()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, store: store)
    }
}
