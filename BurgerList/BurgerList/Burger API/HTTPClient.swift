//
//  HTTPClient.swift
//  BurgerList
//
//  Created by Gustavo Londono on 6/25/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(response: HTTPURLResponse, data: Data), Error>
    
    /*
     The completion handler can be invoked in any thread.
     Clients are responsible to dispatch to appropiate threads, if needed.
     */
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
