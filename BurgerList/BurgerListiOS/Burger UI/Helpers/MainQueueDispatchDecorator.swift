//
//  MainQueueDispatchDecorator.swift
//  BurgerListiOS
//
//  Created by Gustavo on 16/03/22.
//  Copyright © 2022 Gustavo Londono. All rights reserved.
//

import Foundation
import BurgerList

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
}

extension MainQueueDispatchDecorator: BurgerLoader where T == BurgerLoader {
    func load(completion: @escaping (BurgerLoader.Result) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
