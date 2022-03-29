//
//  BurgerImageViewModel.swift
//  BurgerList
//
//  Created by Gustavo on 29/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

public struct BurgerImageViewModel<Image> {
    public let name: String
    public let description: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasDescription: Bool {
        return description != nil
    }
}
