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
    var energyType: EnergyType
    // Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    // Значення, на яке буде зміщуватись дата, для якої будується графік
    @Binding var index: Int
    // Дата, для якої будується графік
    var dateForChart: Date { Calendar.current.date(byAdding: .day, value: index, to: Date.now) ?? Date.now }
    // Відфільтрований масив значень енергії протягом поточного дня
    var arrayForChart: [Energy] {
        energyValueArray.filter {
            Calendar.current.dateComponents([.day, .month, .year], from: $0.date) == Calendar.current.dateComponents([.day, .month, .year], from: dateForChart)
        }
    }
    var emptyArray: [Energy] {
        let newEnergy = Energy(value: 0, date: dateForChart, energyType: energyType)
        return [newEnergy]
    }

    
    var body: some View {
            VStack {
                Text(dateForChart.formatted(date: .complete, time: .omitted))
                
                Chart {
                    ForEach(arrayForChart.isEmpty ? emptyArray : arrayForChart, id: \.self) { item in
                        BarMark(
                            x: .value("Hours", Calendar.current.component(.hour, from: item.date)),
                            y: .value("Value", item.value),
                            width: 15
                        )
                    }
                }
                .frame(width: 400, height: 300)
                .chartYScale(domain: [0, 5])
                .chartXScale(domain: [0, 24])
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 6))
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.width > 0 {
                                    index -= 1
                            } else if value.translation.width < 0 {
                                    index += 1
                            }
                        }
                )
                .padding()
        }
            .animation(.smooth, value: index)
    }
}

#Preview {
    do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Energy.self, configurations: config)

        let example = Energy(value: 3, date: Date.now, energyType: .emotional)
        return EnergyDayChart(energyType: .emotional, energyValueArray: [example], index: .constant(0))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
