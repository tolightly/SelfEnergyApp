//
//  Energy+CoreDataProperties.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 18.09.2023.
//
//

import Foundation
import CoreData


extension Energy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Energy> {
        return NSFetchRequest<Energy>(entityName: "Energy")
    }

    @NSManaged public var value: Int16
    @NSManaged public var date: Date?
    @NSManaged public var energyType: String?

    var unwrappedEnergyType: EnergyType? {
        get {
            guard let energyType = energyType else { return nil }
            return EnergyType(rawValue: energyType)
        }
        set {
            energyType = newValue?.rawValue
        }
    }
}

extension Energy : Identifiable {

}
