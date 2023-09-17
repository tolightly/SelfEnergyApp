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

    @NSManaged public var value: Int16
    @NSManaged public var date: Date?
    @NSManaged public var energyType: NSObject?
    
    public var unwrappedDate: Date {
        date ?? Date.now
    }

}

extension Energy : Identifiable {

}
