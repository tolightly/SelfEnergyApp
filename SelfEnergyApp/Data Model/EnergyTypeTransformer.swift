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

    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let enumValue = value as? EnergyType else { return nil }
        return enumValue.rawValue
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let rawValue = value as? String else { return nil }
        return EnergyType(rawValue: rawValue)
    }
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSNumber.self]
    }

    public static func register() {
        let transformer = EnergyTypeTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
