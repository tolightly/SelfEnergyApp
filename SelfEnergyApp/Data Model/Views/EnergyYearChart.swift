//
//  EnergyYearChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 18.10.2023.
//

import Charts
import SwiftUI

struct EnergyYearChart: View {
    @Environment(\.managedObjectContext) var moc
    let calendar = Calendar.current
    // Дата, для якої будується графік
    var date: Date = Date.now
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]

    // Масив значень для графіку, якщо хочемо отримати відомості за останні 365 днів
    // Треба подумати, як відокремити місяці різних років
    var yearArray: [Energy] {
        let startDate: Date = calendar.date(byAdding: .day, value: -365, to: date) ?? date - (60 * 60 * 24 * 365)
//        print("Start date is: \(startDate)")
        let dataForYearArray = energyValueArray.filter {
            guard let unwrappedDate = $0.date else { return false }
            return unwrappedDate >= startDate && unwrappedDate <= date }
//        print("dataForWeekArray count: \(dataForMonthArray.count)")
        var dailyAveragesForYearArray: [Energy] {
            var array: [Energy] = []
            for index in 1...365 {
                let monthEnergyArray = dataForYearArray.filter {
                    guard let unwrappedDate = $0.date else { return false }
                    return calendar.component(.month, from: unwrappedDate) == index
                }
//                print("Data for dayArray for index: \(index) is: \(dayEnergyArray.count)")
                if !monthEnergyArray.isEmpty {
                    let totalMonthEnergy = monthEnergyArray.reduce(0) { $0 + Double($1.value) }
//                    print("Total day energy is: \(totalDayEnergy)")
                    let averageDayEnergy = totalMonthEnergy / Double(monthEnergyArray.count)
//                    print("Average day energy is: \(averageDayEnergy)")
                    let newEnergy = Energy(context: moc)
                    newEnergy.value = Int16(averageDayEnergy)
                    newEnergy.energyType = energyType.stringValue
                    if let dateForArray = monthEnergyArray.first?.date {
                        newEnergy.date = dateForArray
                    } else {
                        newEnergy.date = date
                    }
                    array.append(newEnergy)
                }
            }
//            print("Final array count is: \(array.count)")
            return array
        }
        return dailyAveragesForYearArray
    }
    
    
    var body: some View {
        if !yearArray.isEmpty {
            Chart {
                ForEach(yearArray, id: \.self) { item in
                    BarMark(
                        x: .value("Days", item.date ?? Date()),
                        y: .value("Value", item.value)
                    )
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXScale(domain: [Date().advanced(by: -60 * 60 * 24 * 365), Date()])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().month(.narrow),
                    values: .automatic(desiredCount: 12)
                )
            }
            .padding()
        } else {
            Text("No data for this month")
        }
    }
}

#Preview {
    @Environment(\.managedObjectContext) var moc
    return EnergyYearChart(energyType: EnergyType.emotional, energyValueArray: [Energy(context: moc)])
}
