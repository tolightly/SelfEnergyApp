//
//  DataController.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 17.09.2023.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "DataModelEnergy")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR with loading persistent storage for DataController's model EnergyDataModel\(error.localizedDescription)")
            }
        }
    }
}
