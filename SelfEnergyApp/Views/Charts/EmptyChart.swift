//
//  EmptyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 13.11.2023.
//

import Charts
import SwiftUI

struct EmptyChart: View {
    
    var body: some View {
        Chart {
            BarMark(
                x: .value("Time", Date()),
                y: .value("Value", 0)
            )
        }
        .chartYAxis {
            AxisMarks(values: [0, 1, 2, 3, 4, 5])
        }
        .chartXAxis {
            AxisMarks(
                format: Date.FormatStyle().day(.defaultDigits),
                values: .automatic(desiredCount: 1)
            )
        }
        .padding()
    }
}

#Preview {
    EmptyChart()
}
