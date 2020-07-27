//
//  HTTPURLResponse+statusCode.swift
//  BurgerList
//
//  Created by Gustavo Londono on 7/27/20.
//  Copyright © 2020 Gustavo Londono. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
