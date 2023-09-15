//
//  CircleOverlay.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 08.09.2023.
//

import SwiftUI

struct CircleOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius: Double = min(geometry.size.width, geometry.size.height) / 2
            
            ForEach(1..<6){ index in
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 2)
                    .frame(width: radius / 5 * Double(index) * 2, height: radius / 5 * Double(index) * 2)
                    .position(center)
            }
        }
    }
}

struct CircleOverlay_Previews: PreviewProvider {
    static var previews: some View {
        CircleOverlay()
    }
}
