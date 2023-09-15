//
//  ContentView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 04.09.2023.
//

import SwiftUI



struct ContentView: View {
    
    var body: some View {
       RadialChart(physicalValue: 1, emotionValue: 2, intelligenceValue: 3, soulValue: 4)
            .padding()
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
