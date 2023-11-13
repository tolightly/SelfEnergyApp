//
//  EnergyStartSeasonChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 12.11.2023.
//

import Charts
import SwiftData
import SwiftUI

struct EnergyHalfYearChart: View {
    let calendar = Calendar.current
    // Дата, для якої будується графік
    var currentDate: Date = Date.now
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    
    var startDate: Date {
        calendar.date(byAdding: .month, value: -6, to: currentDate) ?? currentDate - (60 * 60 * 24 * 183)
    }
    
    // Масив значень для графіку за останні 6 місяців
    var halfYearArray: [Energy] {

        let dataForHalfYearArray = energyValueArray.filter { $0.date >= startDate && $0.date <= currentDate }
        
        let numbersOfWeekComponentsArray = Array(Set(dataForHalfYearArray.compactMap {
            Calendar.current.component(.weekOfYear, from: $0.date)
        })).sorted()
        print("ComponentsArray is: \(numbersOfWeekComponentsArray)")
        
        var weekAveragesForHalfYearArray: [Energy] {
            var array: [Energy] = []
            
            for index in numbersOfWeekComponentsArray {
                let weekEnergyArray = dataForHalfYearArray.filter { calendar.component(.weekOfYear, from: $0.date) == index }
                print("Count weekEnergyArray for index: \(index) is: \(weekEnergyArray.count)")

                if !weekEnergyArray.isEmpty {
                    let totalWeekEnergy = weekEnergyArray.reduce(0) { $0 + Double($1.value) }
                    print("Total day energy is: \(totalWeekEnergy)")
                    let averageWeekEnergy = totalWeekEnergy / Double(weekEnergyArray.count)
                    print("Average day energy is: \(averageWeekEnergy)")
                    var dateForArray: Date {
                        if let dateForArray = weekEnergyArray.first?.date {
                            let components = calendar.dateComponents([.year, .month, .weekOfYear], from: dateForArray)
                            print("components is: \(components)")
                            let formattedDateForArray = calendar.date(from: DateComponents (
                                year: components.year,
                                month: components.month,
                                day: 4,
                                weekOfYear: components.weekOfYear)
                            ) ?? currentDate
                            print("formattedData is: \(formattedDateForArray)")
                                return formattedDateForArray
                        }
                            else {
                            return currentDate
                        }
                    }
                    print("Date for array is: \(dateForArray)")
                    print("startDate is: \(startDate)")
                    print("currentDate is: \(currentDate)")
                    
                    let newEnergy = Energy(value: averageWeekEnergy, date: dateForArray, energyType: energyType)
                    array.append(newEnergy)
                }
            }
            print("Final array count is: \(array.count)")
            return array
        }
        return weekAveragesForHalfYearArray
    }
    
    
    var body: some View {
        if !halfYearArray.isEmpty {
            Chart {
                ForEach(halfYearArray, id: \.self) { item in
                    BarMark(
                        x: .value("Days", item.date),
                        y: .value("Value", item.value),
                        width: 3
                    )
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXScale(domain: [startDate, currentDate])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().month(.abbreviated),
                    values: .automatic(desiredCount: 6)
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
