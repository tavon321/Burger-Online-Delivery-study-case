//
//  BurgerStoreSpy.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 9/16/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class BurgerStoreSpy: BurgerStore {
    
    private (set) var receivedMessages = [ReceivedMessage]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalBurger], Date)
        case retreiveCache
    }
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retreivalCompletions = [RetreivalCompletion]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func retreive(completion: @escaping RetreivalCompletion) {
        retreivalCompletions.append(completion)
        receivedMessages.append(.retreiveCache)
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
    
    func completeRetreival(with error: Error, at index: Int = 0) {
        retreivalCompletions[index](error)
    }
    
    func completeRetreival(with items: [Burger], at index: Int = 0) {
        retreivalCompletions[index](nil)
    }
}
