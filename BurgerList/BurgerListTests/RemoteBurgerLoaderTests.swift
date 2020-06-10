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
    let url: URL
    
    init(httpClient: HTTPClient, url: URL) {
        self.client = httpClient
        self.url = url
    }
    
    func load() {
        client.get(form: url)
    }
}

protocol HTTPClient {
    func get(form url: URL)
}

class RemoteBurgerLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(form url: URL) {
            requestedURL = url
        }
    }
}
