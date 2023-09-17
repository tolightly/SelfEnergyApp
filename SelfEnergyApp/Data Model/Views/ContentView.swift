//
//  ContentView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 04.09.2023.
//

import SwiftUI



struct ContentView: View {
    
    var body: some View {
        NavigationView {
            RadialChart(physicalValue: 1, emotionValue: 2, mentalValue: 3, spiritualValue: 4)
                .padding()
                .navigationTitle("SelfEnergy")
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
