//
//  Energy+CoreDataProperties.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 17.09.2023.
//
//

import Foundation
import CoreData


extension Energy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Energy> {
        return NSFetchRequest<Energy>(entityName: "Energy")
    }

    @NSManaged public var date: Date?
    @NSManaged public var energyTypeString: String?
    @NSManaged public var value: Int16
    
    var energyType: EnergyType? {
        get {
            guard let energyTypeString = energyTypeString else { return nil }
            return EnergyType(rawValue: energyTypeString)
        }
        set {
            energyTypeString = newValue?.rawValue
        }
    }
}


