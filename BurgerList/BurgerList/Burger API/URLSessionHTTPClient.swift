//
//  URLSessionHTTPClient.swift
//  BurgerList
//
//  Created by Gustavo Londono on 7/23/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValue: Error { }
    
    // Wrapper to avoid leaking implementation detail `URLSessionTask` to the client
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((response, data)))
            } else {
                completion(.failure(UnexpectedValue()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
