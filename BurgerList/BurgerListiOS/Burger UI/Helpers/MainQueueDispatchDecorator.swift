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
    
    func dispatch(completion: @escaping () -> Void) {
        guard !Thread.isMainThread else {
            return completion()
        }
        DispatchQueue.main.async {
            completion()
        }
    }
}

extension MainQueueDispatchDecorator: BurgerLoader where T == BurgerLoader {
    func load(completion: @escaping (BurgerLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: BurgerImageLoader where T == BurgerImageLoader {
    func loadImageData(from url: URL, completion: @escaping (BurgerImageLoader.Result) -> Void) -> BurgerImageDataLoadTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
