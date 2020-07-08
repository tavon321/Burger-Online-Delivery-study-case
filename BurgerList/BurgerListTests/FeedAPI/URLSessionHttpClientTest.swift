//
//  URLSessionHttpClientTest.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 7/6/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest
import BurgerList

class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (_, _, error) in
            guard let error = error else { return }
            completion(.failure(error))
        }.resume()
    }
}

class URLSessionHttpClientTest: XCTestCase {

    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
        
        
        let sut = URLSessionHttpClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "an Error", code: 1)
        
        let sut = URLSessionHttpClient(session: session)
        let exp = expectation(description: "Wait for completion")
        
        
        session.stub(url: url, error: error)
        
        sut.get(from: url) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            case let .failure(receivedError as NSError):
                XCTAssertEqual(error, receivedError)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: Helpers
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Spy stub must be created first")
            }
            
            completionHandler(nil, nil, stub.error)
            
            return stub.task
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask { }
}
