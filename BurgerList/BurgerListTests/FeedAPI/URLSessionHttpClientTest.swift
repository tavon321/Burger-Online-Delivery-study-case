//
//  URLSessionHttpClientTest.swift
//  BurgerListTests
//
//  Created by Gustavo Londono on 7/6/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import XCTest

class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { (_, _, _) in }.resume()
    }
}

class URLSessionHttpClientTest: XCTestCase {

    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
        
        
        let sut = URLSessionHttpClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: Helpers
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
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
