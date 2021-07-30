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
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnSeparateInstance() {
        let saveSut = makeSUT()
        let loadSut = makeSUT()
        let burgers = uniqueBurgers().models
        
        expect(saveSut, toSave: burgers)
        expect(loadSut, toLoad: burgers)
    }
    
    func test_save_overrridesItemsSavedOnASeparatedInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        
        let firstBurgers = uniqueBurgers().models
        let lastBurgers = uniqueBurgers().models
        
        expect(sutToPerformFirstSave, toSave: firstBurgers)
        expect(sutToPerformLastSave, toSave: lastBurgers)
        expect(sutToPerformLoad, toLoad: lastBurgers)
    }
    
    // MARK: - Helpers
    private func expect(_ sut: LocalBurgerLoader,
                        toSave burgers: [Burger],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(burgers) { saveError in
            XCTAssertNil(saveError)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 0.1)
    }
    
    private func expect(_ sut: LocalBurgerLoader,
                        toLoad burgers: [Burger],
                        file: StaticString = #file,
                        line: UInt = #line) {
        let loadExp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case .success(let burgerList):
                XCTAssertEqual(burgerList, burgers, file: file, line: line)
            case .failure(let error):
                XCTFail("Expected success, got \(error) instead")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 0.1)
    }
    
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
