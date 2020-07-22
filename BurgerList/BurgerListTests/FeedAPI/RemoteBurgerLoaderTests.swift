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
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClienError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let data = makeItemsJson([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithJSONEmptyList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(name: "", image: URL(string: "https://a-url.com")!)
        let item2 = makeItem(name: "", description: "a description")

        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let data = makeItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteBurgerLoader? = RemoteBurgerLoader(httpClient: client, url: url)
        
        var capturedResults: [RemoteBurgerLoader.Result] = []
        sut?.load { result in
            capturedResults.append(result)
        }
        
        sut = nil
        client.complete(withStatusCode: 200, data: Data())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteBurgerLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteBurgerLoader(httpClient: client, url: url)
        
        trakForMemoryLeaks(sut, file: file, line: line)
        trakForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func trakForMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should have being deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID = UUID(),
                          name: String,
                          description: String? = nil,
                          image: URL? = nil) -> (model: Burger, json: [String: Any]) {
        let model = Burger(id: id, name: name, description: description, imageURL: image)
        let json = [
            "id": id.uuidString,
            "name": name,
            "description": description,
            "image": image?.absoluteString
            ].compactMapValues( { return $0 })
        
        return (model, json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let items = ["items": items]
        return try! JSONSerialization.data(withJSONObject: items)
    }
    
    private func failure(_ error: RemoteBurgerLoader.Error) -> RemoteBurgerLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteBurgerLoader,
                        toCompleteWithResult expectedResult: RemoteBurgerLoader.Result,
                        file: StaticString = #file,
                        line: UInt = #line,
                        when action: () -> Void) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteBurgerLoader.Error), .failure(expectedResult as RemoteBurgerLoader.Error)):
                XCTAssertEqual(receivedError, expectedResult, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) insted", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map( { $0.url })
        }
        
        func get(form url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,
                      data: Data,
                      at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success((response, data)))
        }
    }
}
