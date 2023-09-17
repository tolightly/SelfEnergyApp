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
    var mentalValue: Int
    var spiritualValue: Int
    
    var radiusArray: [CGFloat] {
        [
        CGFloat(Double(physicalValue)),
        CGFloat(Double(emotionValue)),
        CGFloat(Double(spiritualValue)),
        CGFloat(Double(mentalValue))
        ]
    }
    
    var energyTypeArray: [EnergyType] {
        [
        EnergyType.physical,
        EnergyType.emotional,
        EnergyType.spiritual,
        EnergyType.mental
        ]
    }
    
    var colorArray: [Color] = [.green, .red, .purple, .blue]
    
    struct SectorValue: Shape {
        
        let index: Int
        let geometry: GeometryProxy
        let radiusArray: [CGFloat]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
            path.addArc(
                center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                radius: (min(geometry.size.width, geometry.size.height) / 2) / 5 * radiusArray[index],
                startAngle: Angle(degrees: Double(index) * 90 + 225),
                endAngle: Angle(degrees: Double(index + 1) * 90 + 225),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
    }
    
    struct SectorOverlay: Shape {
        
        let index: Int
        let geometry: GeometryProxy
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
            path.addArc(
                center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                radius: (min(geometry.size.width, geometry.size.height) / 2),
                startAngle: Angle(degrees: Double(index) * 90 + 225),
                endAngle: Angle(degrees: Double(index + 1) * 90 + 225),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.secondary)
            
            GeometryReader { geometry in
                ForEach(0..<4, id: \.self) { index in
                    NavigationLink(
                        destination: DetailView(energyType: energyTypeArray[index]),
                        label: {
                            SectorValue(index: index, geometry: geometry, radiusArray: radiusArray)
                                .fill(colorArray[index])
                                
                        }
                    )
                    .contentShape(SectorOverlay(index: index, geometry: geometry))
                }
            }
            .aspectRatio(contentMode: .fit)
            .overlay {
                CircleOverlay()
            }
        }
    }
}

struct RadialChart_Previews: PreviewProvider {
    static var previews: some View {
        RadialChart(physicalValue: 5, emotionValue: 3, mentalValue: 2, spiritualValue: 4)
    }
}
