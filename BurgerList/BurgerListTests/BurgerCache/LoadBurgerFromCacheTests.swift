//
//  LoadBurgerFromCacheTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 9/16/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class LoadBurgerFromCacheTests: XCTestCase {
    
    func test_init_doesnotMessageStoreUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.receivedMessages, [])
    }
    
    func test_load_requestCacheRetreival() {
        let (sut, client) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(client.receivedMessages, [.retreiveCache])
    }
    
    func test_load_failsErrorOnStoreError() {
        let (sut, client) = makeSUT()
        let expectedError = anyError
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for error")
        sut.load { error in
            receivedError = error
            exp.fulfill()
        }
        
        client.completeRetreival(with: expectedError)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalBurgerLoader, store: BurgerStoreSpy) {
        let store = BurgerStoreSpy()
        let sut = LocalBurgerLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut: sut, store: store)
    }
    
    var anyError: NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
