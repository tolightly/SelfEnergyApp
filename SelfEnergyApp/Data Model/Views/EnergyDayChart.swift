//
//  EnergyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 06.10.2023.
//

import Charts
import SwiftUI

struct EnergyDayChart: View {
    // Дата, для якої будується графік
    var date: Date = Date.now
    // Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    // Відфільтрований масив значень енергії протягом поточного дня
    var arrayForChart: [Energy] {
        energyValueArray.filter {
            Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year], from: $0.date ?? Date.now) == Calendar.autoupdatingCurrent.dateComponents([.day, .month, .year], from: date)
        }
    }
    
    var body: some View {
        if !arrayForChart.isEmpty {
            Chart {
                ForEach(arrayForChart, id: \.self) { item in
                    BarMark(
                        x: .value("Hours", Calendar.autoupdatingCurrent.component(.hour, from: item.date ?? Date.now)),
                        y: .value("Value", item.value)
                    )
//                    .lineStyle(StrokeStyle(lineCap: .round, lineJoin: .round))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])
            }
        } else {
            Text("No data for today")
        }
    }
}

#Preview {
    @Environment(\.managedObjectContext) var moc
     return EnergyDayChart(energyValueArray: [Energy(context: moc)])
}
