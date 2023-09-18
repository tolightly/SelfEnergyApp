//
//  SelfEnergyAppApp.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 04.09.2023.
//

import SwiftUI

@main
struct SelfEnergyAppApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
