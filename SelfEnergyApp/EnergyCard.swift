//
//  EnergyCard.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 04.09.2023.
//

import SwiftUI

struct EnergyCard: View {
    
    var color: Color
    
    var body: some View {
        ZStack {
        RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(color.opacity(0.7))
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
    }
    }
}

struct EnergyCard_Previews: PreviewProvider {
    static var previews: some View {
        EnergyCard(color: .red)
    }
}
