//
//  HTTPClient.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/25/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(HTTPURLResponse, Data), Error>
    
    func get(form url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
