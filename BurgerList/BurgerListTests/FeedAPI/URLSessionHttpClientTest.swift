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

    func test_getFromUrl_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "an Error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        
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
        private static var stubs = [URL: Stub]()
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptionRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs.removeAll()
        }
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
