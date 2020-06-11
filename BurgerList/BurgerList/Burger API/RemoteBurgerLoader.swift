//
//  RemoteBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(form url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteBurgerLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(httpClient: HTTPClient, url: URL) {
        self.client = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteBurgerLoader.Error) -> Void = { _ in }) {
        client.get(form: url) { error in
            completion(.connectivity)
        }
    }
}
