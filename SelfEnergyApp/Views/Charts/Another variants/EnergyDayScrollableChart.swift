//
//  EnergyDayScrollableChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 15.11.2023.
//
import Charts
import SwiftData
import SwiftUI

struct EnergyDayScrollableChart: View {
    // Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    
    var body: some View {
            VStack {
//                Text(dateForChart.formatted(date: .complete, time: .omitted))
                
                if !energyValueArray.isEmpty {
                Chart {
                    ForEach(energyValueArray, id: \.self) { item in
                        BarMark(
                            x: .value("Hours", item.date),
                            y: .value("Value", item.value)
                        )
                    }
                }
                .chartScrollableAxes(.horizontal)
                .chartScrollTargetBehavior(
                    .valueAligned(
                        matching: DateComponents(hour: 0),
                        majorAlignment: .matching(DateComponents(hour: 0))
                    )
                )
                .chartYAxis {
                    AxisMarks(values: [0, 1, 2, 3, 4, 5])
                }
                .chartXAxis {
                    AxisMarks(
                        format: Date.FormatStyle().hour(),
                        values: .automatic
                    )
                }
                .padding()
            }
        }
    }
}

#Preview {
    do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Energy.self, configurations: config)

        let example = Energy(value: 3, date: Date.now, energyType: .emotional)
            return EnergyDayScrollableChart(energyValueArray: [example])
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
