//
//  SelfEnergyAppApp.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 04.09.2023.
//
import SwiftData
import SwiftUI

@main
struct SelfEnergyAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Energy.self)
    }
}
