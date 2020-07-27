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
        
    }
    
    // Helpers
    private func getBurgerResult() -> BurgerLoader.Result {
        let testServerURL = URL(string: "https://localhost:3000/burgerList")!
        let client = URLSessionHTTPClient()
        let loader = RemoteBurgerLoader(httpClient: client, url: testServerURL)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(loader)
        
        let exp = expectation(description: "wait for load completion")
        
        var captureResult: BurgerLoader.Result?
        loader.load { result in
            captureResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return captureResult
    }
}
