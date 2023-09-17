//
//  EnergyValue.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 13.09.2023.
//

import Foundation

struct EnergyValue: Identifiable, Hashable {
    var id = UUID()
    let type: EnergyType
    let date: Date
    let value: Int
    
    
    static var example: [EnergyValue] {
        [EnergyValue(type: .physical, date: Date.now, value: 5),
         EnergyValue(type: .physical, date: Date(timeIntervalSinceNow: 24 * 60 * 60), value: 2),
         EnergyValue(type: .physical, date: Date(timeIntervalSinceNow: 2 * 24 * 60 * 60), value: 3),
         EnergyValue(type: .physical, date: Date(timeIntervalSinceNow: 3 * 24 * 60 * 60), value: 1)
        ]
    }
}
