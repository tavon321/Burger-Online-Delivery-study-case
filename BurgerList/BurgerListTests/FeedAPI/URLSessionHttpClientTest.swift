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
    
    init(session: URLSession = .shared) {
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
    
    func test_getFromURL_performGETRequestWithURL() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://any-url.com")!
        let sut = URLSessionHttpClient()
        
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observerRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        sut.get(from: url) { _ in }
        
        URLProtocolStub.stopInterceptionRequest()
    }

    func test_getFromUrl_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "an Error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = URLSessionHttpClient()
        let exp = expectation(description: "Wait for completion")
        
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
        
        URLProtocolStub.stopInterceptionRequest()
    }
    
    // MARK: Helpers
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptionRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static func observerRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
