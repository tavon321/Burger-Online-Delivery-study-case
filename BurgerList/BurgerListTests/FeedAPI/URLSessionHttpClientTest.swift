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
    
    struct UnexpectedValue: Error { }
    
    func get(from url: URL, completion: @escaping (HTTPClient.HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((response, data)))
            } else {
                completion(.failure(UnexpectedValue()))
            }
        }.resume()
    }
}

class URLSessionHttpClientTest: XCTestCase {
    
    override func setUpWithError() throws {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDownWithError() throws {
        URLProtocolStub.stopInterceptionRequest()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observerRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let requestedError = anyError
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestedError)
        
        XCTAssertEqual(requestedError, receivedError as NSError?)
    }

    func test_getFromUrl_failsOnAllInvalidCasesValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTTPURLResponse, error: nil))
    }
    
    func test_getFromURL_succeedOnHTTPResponseURLWithData() {
        let expectedData = anyData
        let expectedHTTPResponse = anyHTTTPURLResponse
        URLProtocolStub.stub(data: expectedData, response: expectedHTTPResponse, error: nil)
        
        let exp = expectation(description: "wait for result")
        makeSUT().get(from: anyURL) { result in
            switch result {
            case .success((let receivedResponse, let receivedData)):
                XCTAssertEqual(receivedResponse.url, expectedHTTPResponse.url)
                XCTAssertEqual(receivedResponse.statusCode, expectedHTTPResponse.statusCode)
                
                XCTAssertEqual(expectedData, receivedData)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_succeedWithEmptyDataOnHTTPResponseURLWithNilData() {
           let expectedData = Data()
           let expectedHTTPResponse = anyHTTTPURLResponse
           URLProtocolStub.stub(data: nil, response: expectedHTTPResponse, error: nil)
           
           let exp = expectation(description: "wait for result")
           makeSUT().get(from: anyURL) { result in
               switch result {
               case .success((let receivedResponse, let receivedData)):
                   XCTAssertEqual(receivedResponse.url, expectedHTTPResponse.url)
                   XCTAssertEqual(receivedResponse.statusCode, expectedHTTPResponse.statusCode)
                   
                   XCTAssertEqual(expectedData, receivedData)
               default:
                   XCTFail("Expected success, got \(result) instead")
               }
               
               exp.fulfill()
           }
           
           wait(for: [exp], timeout: 1)
       }
    
    // MARK: Helpers
    var anyError: NSError {
        return NSError(domain: "any error", code: 0)
    }
    var anyURL: URL {
        return URL(string: "http://any-url.com")!
    }
    
    var anyData: Data {
        return Data("any data".utf8)
    }
    
    var nonHTTTPURLResponse: URLResponse {
        return URLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    var anyHTTTPURLResponse: HTTPURLResponse {
        return HTTPURLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for completion")

        var capturedError: Error?
        makeSUT().get(from: anyURL) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            case .failure(let receivedError):
                capturedError = receivedError
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        
        return capturedError
    }
    
    private func makeSUT() -> URLSessionHttpClient {
        return URLSessionHttpClient()
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptionRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
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
