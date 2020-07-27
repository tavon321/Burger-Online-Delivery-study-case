//
//  RemoteBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public final class RemoteBurgerLoader: BurgerLoader {
    public typealias Result = BurgerLoader.BurgerListResult
    
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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let successTuple):
                completion(BurgerMapper.map(successTuple.data, response: successTuple.response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
 
}
