//
//  EnergyType.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 17.09.2023.
//

import Foundation

public enum EnergyType: String {
    
    case physical, emotional, mental, spiritual
    
    var stringValue: String {
        switch self {
        case .physical:
            return "Physical"
        case .emotional:
            return "Emotional"
        case .mental:
            return "Mental"
        case .spiritual:
            return "Spiritual"
        }
    }
}
