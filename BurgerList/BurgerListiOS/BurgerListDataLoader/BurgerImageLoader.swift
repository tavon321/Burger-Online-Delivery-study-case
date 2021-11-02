//
//  BurgerImageLoader.swift
//  BurgerListiOS
//
//  Created by Gustavo on 2/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation

public protocol BurgerImageLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL,
                       completion: @escaping (Result) -> Void) -> BurgerImageDataLoadTask
}
