//
//  BurgerStoreSpecs.swift
//  BurgerListTests
//
//  Created by Gustavo Londoño on 17/03/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation

typealias FailableBurgeStore = FailableRetreiveBurgerStoreSpecs & FailableInsertBurgerStoreSpecs & FailableDeleteBurgerStoreSpecs

protocol BurgerStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversValueOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_overridesProviouslyInsertedValues()
    
    func test_delete_hasNoSideEffects()
    func test_delete_emptiesPreviouslyInsertedCache()
    
    func test_storeSideEffects_runSerially()
}

protocol FailableRetreiveBurgerStoreSpecs: BurgerStoreSpecs {
    func test_retreive_deliversFailureOnRetreivalError()
    func test_retreive_hasNoSideEffectsOnRetreivalError()
}

protocol FailableInsertBurgerStoreSpecs: BurgerStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteBurgerStoreSpecs: BurgerStoreSpecs {
    func test_delete_deliversErrorOnInsertionError()
    func test_delete_hasNoSideEffectsOndeletionError()
}
