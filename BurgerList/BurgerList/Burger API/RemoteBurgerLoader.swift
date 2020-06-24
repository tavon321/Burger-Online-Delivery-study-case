//
//  RemoteBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(HTTPURLResponse, Data), Error>
    
    func get(form url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteBurgerLoader {
    public typealias Result = Swift.Result<[Burger], Error>
    
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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(form: url) { result in
            switch result {
            case .success(let successTuple):
                let (response, data) = successTuple
                if response.statusCode == 200,
                    let root = try? JSONDecoder().decode(BurgerRoot.self, from: data) {
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


private struct BurgerRoot: Decodable {
    let items: [Burger]
}
