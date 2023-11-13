//
//  EnergyStartWeekChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 11.11.2023.
//

import Charts
import SwiftData
import SwiftUI

struct EnergyStartWeekChart: View {
// Дата, для якої будується графік
    var date: Date = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: Date()) ?? Date()
    let calendar = Calendar.current
    let energyType: EnergyType
// Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    var firstDayOfWeek: Date {
        let components = calendar.dateComponents([.weekOfYear, .year], from: Date())
        
        let date = calendar.date(from: DateComponents(
            year: components.year,
            weekday: 2,
            weekOfYear: components.weekOfYear)
        )
        return date ?? Date()
    }

    

// Відфільтрований масив значень енергії протягом поточного тижня, з початку тижня
    var weekArrayFromStart: [Energy] {
        let dataForWeekArray = energyValueArray.filter {
            calendar.dateComponents([.weekOfYear, .year], from: $0.date) == calendar.dateComponents([.weekOfYear, .year], from: Date())
        }
        var dailyAveragesForWeekArray: [Energy] {
            var array: [Energy] = []
            for index in 1...7 {
                let dayEnergyArray = dataForWeekArray.filter { calendar.component(.weekday, from: $0.date) == index }

                if !dayEnergyArray.isEmpty {
                    let totalDayEnergy = dayEnergyArray.reduce(0) { $0 + Double($1.value) }
                    let averageDayEnergy = totalDayEnergy / Double(dayEnergyArray.count)
                    var dateForArray: Date {
                        if let date = dayEnergyArray.first?.date {
                            let dateForArray = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
                            return dateForArray
                        } else {
                            return date
                        }
                    }
                    let newEnergy = Energy(value: averageDayEnergy, date: dateForArray, energyType: energyType)
                    array.append(newEnergy)
                }
            }
            return array
        }
        return dailyAveragesForWeekArray
    }
    
    
    
    var body: some View {
        if !weekArrayFromStart.isEmpty {
            Chart {
                ForEach(weekArrayFromStart, id: \.self) { item in
                    BarMark(
                        x: .value("Day", item.date),
                        y: .value("Value", item.value)
                    )
                }
            }
            .chartYScale(domain: [0, 5])
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXScale(domain: [firstDayOfWeek, firstDayOfWeek.advanced(by: 60 * 60 * 24 * 7)])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().weekday(.narrow),
                    values: .automatic(desiredCount: 7)
                )
            }
            .padding()
        } else {
            Text("No data for this week")
        }
    }
}


#Preview {
    do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Energy.self, configurations: config)

        let example = [
            Energy(value: 1, date: Date.now - 6 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 2, date: Date.now - 5 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 3, date: Date.now - 4 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 4, date: Date.now - 3 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 5, date: Date.now - 2 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 2, date: Date.now - 1 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 4, date: Date.now - 0 * 24 * 60 * 60, energyType: .emotional)
            ]
            return EnergyDayChart(energyValueArray: example)
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
