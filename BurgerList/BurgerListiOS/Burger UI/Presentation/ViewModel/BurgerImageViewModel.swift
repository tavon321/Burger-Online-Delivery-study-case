//
//  BurgerImageViewModel.swift
//  BurgerListiOS
//
//  Created by Gustavo on 24/11/21.
//  Copyright © 2021 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

struct BurgerImageViewModel<Image> {
    var name: String
    var description: String?
    var image: Image?
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasDescription: Bool {
        return description != nil
    }
}
