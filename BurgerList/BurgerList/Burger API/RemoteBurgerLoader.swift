//
//  RemoteBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = (Result<(URLResponse, Data), Error>) -> ()
    
    func get(form url: URL, completion: @escaping HTTPClientResult)
}

public final class RemoteBurgerLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(httpClient: HTTPClient, url: URL) {
        self.client = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteBurgerLoader.Error) -> Void) {
        client.get(form: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
