//
//  RemoteFeedLoader.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/10/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

class RemoteBurgerLLoader {
    let client: HTTPClient
    let url: URL
    
    init(httpClient: HTTPClient, url: URL) {
        self.client = httpClient
        self.url = url
    }
    
    func load() {
        client.get(form: url)
    }
}
