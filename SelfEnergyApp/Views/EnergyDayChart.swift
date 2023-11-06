//
//  EnergyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 06.10.2023.
//

import Charts
import SwiftData
import SwiftUI

struct EnergyDayChart: View {
    // Дата, для якої будується графік
    var date: Date = Date.now
    // Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    // Відфільтрований масив значень енергії протягом поточного дня
    var arrayForChart: [Energy] {
        energyValueArray.filter {
            Calendar.current.dateComponents([.day, .month, .year], from: $0.date) == Calendar.current.dateComponents([.day, .month, .year], from: date)
        }
    }
    
    var body: some View {
        if !arrayForChart.isEmpty {
            Chart {
                ForEach(arrayForChart, id: \.self) { item in
                    BarMark(
                        x: .value("Hours", Calendar.current.component(.hour, from: item.date)),
                        y: .value("Value", item.value)
                    )
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXAxis {
                AxisMarks(values: [0, 3, 6, 9, 12, 15, 18, 21])
            }
            .padding()
        } else {
            Text("No data for today")
        }
    }
}

#Preview {
    do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Energy.self, configurations: config)

        let example = Energy(value: 3, date: Date.now, energyType: .emotional)
            return EnergyDayChart(energyValueArray: [example])
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
