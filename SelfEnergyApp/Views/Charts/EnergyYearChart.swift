//
//  EnergyYearChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 18.10.2023.
//

import Charts
import SwiftData
import SwiftUI

struct EnergyYearChart: View {
    let calendar = Calendar.current
    // Дата, для якої будується графік
    var currentDate: Date = Date.now
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    
    var startDate: Date {
        calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate - (60 * 60 * 24 * 365)
    }

    // Масив значень для графіку, якщо хочемо отримати відомості за останній рік
    // Треба подумати, як відокремити місяці різних років
    var yearArray: [Energy] {
        
        let dataForYearArray = energyValueArray.filter { $0.date >= startDate && $0.date <= currentDate }
//        print("dataForWeekArray count: \(dataForYearArray.count)")
        
        let numbersOfMonthComponentsArray = Array(Set(dataForYearArray.compactMap { calendar.component(.month, from: $0.date)})).sorted()
//        print("NumbersOfMonthComponentArray is: \(numbersOfMonthComponentsArray)")
        
        var monthlyAveragesForYearArray: [Energy] {
            var array: [Energy] = []
            
            for index in numbersOfMonthComponentsArray {
                let monthEnergyArray = dataForYearArray.filter { calendar.component(.month, from: $0.date) == index }
//                print("Count for Array for index: \(index) is: \(monthEnergyArray.count)")
                
                if !monthEnergyArray.isEmpty {
                    let totalMonthEnergy = monthEnergyArray.reduce(0) { $0 + Double($1.value) }
//                    print("Total month energy is: \(totalMonthEnergy)")
                    let averageMonthEnergy = totalMonthEnergy / Double(monthEnergyArray.count)
//                    print("Average month energy is: \(averageMonthEnergy)")
                    var dateForArray: Date {
                        if let dateForArray = monthEnergyArray.first?.date {
                            let components = calendar.dateComponents([.year, .month], from: dateForArray)
//                            print("components is: \(components)")
                            let formattedDateForArray = calendar.date(from: DateComponents (
                                year: components.year,
                                month: components.month
                                )
                            ) ?? currentDate
//                            print("formattedDateForArray is: \(formattedDateForArray)")
                                return formattedDateForArray
                        }
                            else {
                            return currentDate
                        }
                    }
                    
                    let newEnergy = Energy(value: averageMonthEnergy, date: dateForArray, energyType: energyType)
                    array.append(newEnergy)
                }
            }
//            print("Final array count is: \(array.count)")
//            print("Start date is: \(startDate)")
//            print("current date is: \(currentDate)")
            return array
        }
        return monthlyAveragesForYearArray
    }
    
    
    var body: some View {
        if !yearArray.isEmpty {
            Chart {
                ForEach(yearArray, id: \.self) { item in
                    BarMark(
                        x: .value("Months", item.date),
                        y: .value("Value", item.value)
                    )
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXScale(domain: [startDate, currentDate])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().month(.narrow),
                    values: .automatic(desiredCount: 12)
                )
            }
            .padding()
        } else {
            EmptyChart()
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
        return EnergyYearChart(energyType: .emotional, energyValueArray: example)
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
