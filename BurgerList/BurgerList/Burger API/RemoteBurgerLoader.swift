//
//  RemoteBurgerLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(form url: URL)
}

public final class RemoteBurgerLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(httpClient: HTTPClient, url: URL) {
        self.client = httpClient
        self.url = url
    }
    
    public func load() {
        client.get(form: url)
    }
}
