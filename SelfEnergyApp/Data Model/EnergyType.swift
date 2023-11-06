//
//  EnergyType.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 06.11.2023.
//
import Foundation

public enum EnergyType: String, Codable {
    
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
