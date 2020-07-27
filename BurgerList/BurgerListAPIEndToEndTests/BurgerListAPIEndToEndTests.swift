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
        let testServerURL = URL(string: "https://localhost:3000/burgerList")!
        let client = URLSessionHTTPClient()
        let loader = RemoteBurgerLoader(httpClient: client, url: testServerURL)
        
        let exp = expectation(description: "wait for load completion")
    }
}
