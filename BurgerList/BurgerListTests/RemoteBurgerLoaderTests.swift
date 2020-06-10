//
//  RemoteBurgerLoaderTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 6/9/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(httpClient: HTTPClient) {
        client = httpClient
    }
    
    func load() {
        client.get(form: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(form url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(form url: URL) {
        requestedURL = url
    }
}

class RemoteBurgerLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(httpClient: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
