//
//  RadialChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 07.09.2023.
//

import SwiftUI

struct RadialChart: View {
    var physicalValue: Int
    var emotionValue: Int
    var intelligenceValue: Int
    var soulValue: Int
    
    var radiusArray: [CGFloat] {
        [
        CGFloat(Double(physicalValue)),
        CGFloat(Double(emotionValue)),
        CGFloat(Double(soulValue)),
        CGFloat(Double(intelligenceValue))
        ]
    }
    
    var colorArray: [Color] = [.green, .red, .purple, .blue]
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.secondary)
            
            ForEach(0..<4) { index in
                let startAngle = Angle(degrees: Double(index) * 90 + 225)
                let endAngle = Angle(degrees: Double(index + 1) * 90 + 225)
                GeometryReader { geometry in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let radius = min(geometry.size.width, geometry.size.height) / 2
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius / 5 * radiusArray[index],
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                    }
                    .fill(colorArray[index])
                }
                .aspectRatio(contentMode: .fit)
                .overlay {
                    CircleOverlay()
                }
            }
            
        }
    }
}

struct RadialChart_Previews: PreviewProvider {
    static var previews: some View {
        RadialChart(physicalValue: 5, emotionValue: 3, intelligenceValue: 2, soulValue: 4)
    }
}
