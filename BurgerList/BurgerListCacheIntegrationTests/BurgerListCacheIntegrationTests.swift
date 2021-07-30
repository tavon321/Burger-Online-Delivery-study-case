//
//  BurgerListCacheIntegrationTests.swift
//  BurgerListCacheIntegrationTests
//
//  Created by Gustavo on 28/07/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class BurgerListCacheIntegrationTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        setupEmptyState()
    }
    
    override func setUp() {
        super.setUp()
        
        undoStoreChanges()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case .success(let burgerList):
                XCTAssertEqual(burgerList, [], "Expected empty feed")
                
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_load_deliversItemsSavedOnSeparateInstance() {
        let saveSut = makeSUT()
        let loadSut = makeSUT()
        let burgers = uniqueBurgers().models
        
        let saveExp = expectation(description: "Wait for save completion")
        saveSut.save(burgers) { saveError in
            XCTAssertNil(saveError)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 0.1)
        
        let loadExp = expectation(description: "Wait for load completion")
        loadSut.load { result in
            switch result {
            case .success(let burgerList):
                XCTAssertEqual(burgerList, burgers)
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalBurgerLoader {
        let store = try! CoreDataBurgerStore(storeURL: testSpecificStoreURL())
        let sut =  LocalBurgerLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func setupEmptyState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreChanges() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
