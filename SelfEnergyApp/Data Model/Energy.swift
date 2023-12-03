//
//  Energy.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 06.11.2023.
//

import Charts
import Foundation
import SwiftData

@Model
class Energy {
    
    var value: Double
    @Attribute(.unique) var date: Date
    var energyType: String
    
    init(value: Double = 0, date: Date = Date.now, energyType: EnergyType) {
        self.value = value
        self.date = date
        self.energyType = energyType.rawValue
    }
    
}
