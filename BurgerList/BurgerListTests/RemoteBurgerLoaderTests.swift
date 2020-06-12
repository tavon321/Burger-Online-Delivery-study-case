//
//  RemoteBurgerLoaderTests.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 6/9/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class RemoteBurgerLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        let (_, client) = makeSUT()
        XCTAssert(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwict_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClienError() {
        let (sut, client) = makeSUT()
        
        let clientError = NSError(domain: "test", code: 0)
        
        var capturedErrors: [RemoteBurgerLoader.Error] = []
        sut.load { error in
            capturedErrors.append(error)
        }
        
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, code in
            var capturedErrors: [RemoteBurgerLoader.Error] = []
            
            sut.load { error in
                capturedErrors.append(error)
            }
            
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // TODO add invalid data to the error
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteBurgerLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBurgerLoader(httpClient: client, url: url)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: HTTPClient.HTTPClientResult)] = []
        var requestedURLs: [URL] {
            return messages.map( { $0.url })
        }
        
        func get(form url: URL, completion: @escaping HTTPClient.HTTPClientResult) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(response))
        }
    }
}
