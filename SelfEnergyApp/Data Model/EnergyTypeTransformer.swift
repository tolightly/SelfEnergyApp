//
//  EnergyTypeTransformer.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 17.09.2023.
//

import Foundation

@objc(EnergyTypeTransformer)
final class EnergyTypeTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: EnergyTypeTransformer.self))

    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSNumber.self]
    }

    public static func register() {
        let transformer = EnergyTypeTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

