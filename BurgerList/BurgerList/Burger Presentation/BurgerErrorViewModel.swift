//
//  BurgerErrorViewModel.swift
//  BurgerList
//
//  Created by Gustavo on 28/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation

public struct BurgerErrorViewModel {
    public var errorMessage: String?
    
    public static var noError: BurgerErrorViewModel {
        BurgerErrorViewModel(errorMessage: nil)
    }
    
    public static func error(message: String) -> BurgerErrorViewModel {
        BurgerErrorViewModel(errorMessage: message)
    }
}
