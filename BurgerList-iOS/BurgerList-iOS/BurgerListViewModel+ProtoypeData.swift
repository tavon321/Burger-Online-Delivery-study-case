//
//  BurgerListViewModel+ProtoypeData.swift
//  BurgerList-iOS
//
//  Created by Gustavo on 3/08/21.
//

import Foundation

extension BurgerListViewModel {
    static var prototypeFeed: [BurgerListViewModel] {
        return [
            BurgerListViewModel(
                title: "East Side Gallery\nMemorial in Berlin, Germany",
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                imageName: "image-0"
            ),
            BurgerListViewModel(
                title: "Cannon Street, London", description: nil,
                imageName: "image-1"
            ),
            BurgerListViewModel(
                title: "Burger Urger",
                description: "The Desert Island in Faro is beautiful!! ☀️",
                imageName: nil
            ),
            BurgerListViewModel(
                title: "Glorious day in Brighton!! 🎢", description: nil,
                imageName: nil
            ),
            BurgerListViewModel(
                title: "Garth Pier\nNorth Wales",
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales. At 1,500 feet in length, it is the second-longest pier in Wales, and the ninth longest in the British Isles.",
                imageName: "image-2"
            )
        ]
    }
}
