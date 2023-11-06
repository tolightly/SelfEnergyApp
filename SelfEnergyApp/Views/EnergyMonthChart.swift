//
//  EnergyMonthChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 11.10.2023.
//

import Charts
import SwiftData
import SwiftUI

struct EnergyMonthChart: View {
    let calendar = Calendar.current
    // Дата, для якої будується графік
    var date: Date = Date.now
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    
    // Масив значень для графіку, якщо хочемо отримати відомості за останні 30 днів
    var monthArray30Days: [Energy] {
        let startDate: Date = calendar.date(byAdding: .day, value: -30, to: date) ?? date - (60 * 60 * 24 * 30)
//        print("Start date is: \(startDate)")
        let dataForMonthArray = energyValueArray.filter { $0.date >= startDate && $0.date <= date }
//        print("dataForWeekArray count: \(dataForMonthArray.count)")
        var dailyAveragesForWeekArray: [Energy] {
            var array: [Energy] = []
            for index in 1...30 {
                let dayEnergyArray = dataForMonthArray.filter {
                    calendar.component(.weekday, from: $0.date) == index
                }
//                print("Data for dayArray for index: \(index) is: \(dayEnergyArray.count)")
                if !dayEnergyArray.isEmpty {
                    let totalDayEnergy = dayEnergyArray.reduce(0) { $0 + Double($1.value) }
//                    print("Total day energy is: \(totalDayEnergy)")
                    let averageDayEnergy = totalDayEnergy / Double(dayEnergyArray.count)
//                    print("Average day energy is: \(averageDayEnergy)")
                    var dateForArray: Date {
                        if let dateForArray = dayEnergyArray.first?.date {
                            let formattedDateForArray = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateForArray)
                                return formattedDateForArray ?? date
                        } else {
                            return date
                        }
                    }
                    
                    let newEnergy = Energy(value: averageDayEnergy, date: dateForArray, energyType: energyType)
                    array.append(newEnergy)
                }
            }
//            print("Final array count is: \(array.count)")
            return array
        }
        return dailyAveragesForWeekArray
    }
    
    var body: some View {
        if !monthArray30Days.isEmpty {
            Chart {
                ForEach(monthArray30Days, id: \.self) { item in
                    BarMark(
                        x: .value("Days", item.date),
                        y: .value("Value", item.value)
                    )
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXScale(domain: [Date().advanced(by: -60 * 60 * 24 * 30), Date()])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().day(.defaultDigits),
                    values: .automatic(desiredCount: 10)
                )
            }
            .padding()
        } else {
            Text("No data for this month")
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
