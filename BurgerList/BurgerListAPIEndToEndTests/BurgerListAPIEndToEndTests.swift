//
//  BurgerListAPIEndToEndTests.swift
//  BurgerListAPIEndToEndTests
//
//  Created by Gustavo Londono on 7/23/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class BurgerListAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestGetBurgerResult_matchesFixedTestAccountData() {
        switch getBurgerResult() {
        case .success(let burgers):
            burgers.enumerated().forEach { (index, receivedBurger) in
                XCTAssertEqual(receivedBurger, expectedItem(at: index))
            }
        default:
            XCTFail("Expected Success")
        }
    }
    
    // Helpers
    private func getBurgerResult() -> BurgerLoader.Result? {
        let testServerURL = URL(string: "https://5f1ed78757e3290016863dd1.mockapi.io/burgers")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteBurgerLoader(httpClient: client, url: testServerURL)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(loader)
        
        let exp = expectation(description: "wait for load completion")
        
        var captureResult: BurgerLoader.Result?
        loader.load { result in
            captureResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3)
        
        return captureResult
    }
    
    func expectedItem(at index: Int) -> Burger {
        return Burger(id: id(at: index),
                      name: name(at: index),
                      description: description(at: index),
                      imageURL: image(at: index))
    }
    
    func id(at index: Int) -> UUID {
        return [UUID(uuidString: "f9b3f3ca-4984-4648-b6d3-0983581b8b4e")!,
                UUID(uuidString: "fc40a426-fe1f-42c8-87fe-de4e4b7ca190")!,
                UUID(uuidString: "e8017929-5a22-4499-831e-6a08c5facf3f")!,
                UUID(uuidString: "7f0c8c03-7671-47f1-af05-070cc840feaa")!,
                UUID(uuidString: "8d6b8d78-4581-4c68-8c79-8301f862fe4d")!][index]
    }
    
    func name(at index: Int) -> String {
        return ["name 1", "name 2", "name 3", "name 4", "name 5"][index]
    }
    
    func description(at index: Int) -> String? {
        return ["description 1", "description 2", "description 3", "description 4", "description 5"][index]
    }
    
    func image(at index: Int) -> URL? {
        return [URL(string: "http://lorempixel.com/640/480/transport"),
                URL(string: "http://lorempixel.com/640/480/animals"),
                URL(string: "http://lorempixel.com/640/480/cats"),
                URL(string: "http://lorempixel.com/640/480/people"),
                URL(string: "http://lorempixel.com/640/480/food")][index]
    }
}
