//
//  HTTPClientSpy.swift
//  BurgerListTests
//
//  Created by Gustavo on 14/07/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

class HTTPClientSpy: HTTPClient {
    private var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] {
        return messages.map( { $0.url })
    }
    
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
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
