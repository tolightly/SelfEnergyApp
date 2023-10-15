//
//  EnergyWeekChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 11.10.2023.
//

import Charts
import SwiftUI

struct EnergyWeekChart: View {
    @Environment(\.managedObjectContext) var moc
// Дата, для якої будується графік
    var date: Date = Calendar.autoupdatingCurrent.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
    let calendar = Calendar.autoupdatingCurrent
    let energyType: EnergyType
// Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    
    
// Відфільтрований масив значень енергії протягом поточного тижня, з початку тижня
    var weekArrayFromStart: [Energy] {
        let dataForWeekArray = energyValueArray.filter {
            calendar.dateComponents([.weekOfYear, .year], from: $0.date ?? Date.now) == calendar.dateComponents([.weekOfYear, .year], from: Date())
        }
//        print("Data for weekArray count is: \(String(dataForWeekArray.count))")
        var dailyAveragesForWeekArray: [Energy] {
            var array: [Energy] = []
            for index in 1...7 {
                let dayEnergyArray = dataForWeekArray.filter {
                    calendar.component(.weekday, from: $0.date ?? Date.now) == index
                }
//                print("Data for dayArray for index: \(index) is: \(dayEnergyArray.count)")
                if !dayEnergyArray.isEmpty {
                    let totalDayEnergy = dayEnergyArray.reduce(0) { $0 + Double($1.value) }
//                    print("Total day energy is: \(totalDayEnergy)")
                    let averageDayEnergy = totalDayEnergy / Double(dayEnergyArray.count)
//                    print("Average day energy is: \(averageDayEnergy)")
                    let newEnergy = Energy(context: moc)
                    newEnergy.value = Int16(averageDayEnergy)
                    newEnergy.energyType = energyType.stringValue
                    if let dateForArray = dayEnergyArray.first?.date {
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
        return dailyAveragesForWeekArray
    }
// Масив значень для графіку, якщо хочемо отримати відомості за останні 7 днів
    var weekArraySevenDays: [Energy] {
        let startDate: Date = calendar.date(byAdding: .day, value: -7, to: date) ?? date - (60 * 60 * 24 * 7)
//        print("Start date is: \(startDate)")
        let dataForWeekArray = energyValueArray.filter { $0.date! >= startDate && $0.date! <= date }
//        print("dataForWeekArray count: \(dataForWeekArray.count)")
        var dailyAveragesForWeekArray: [Energy] {
            var array: [Energy] = []
            for index in 1...7 {
                let dayEnergyArray = dataForWeekArray.filter {
                    calendar.component(.weekday, from: $0.date ?? Date.now) == index
                }
//                print("Data for dayArray for index: \(index) is: \(dayEnergyArray.count)")
                if !dayEnergyArray.isEmpty {
                    let totalDayEnergy = dayEnergyArray.reduce(0) { $0 + Double($1.value) }
//                    print("Total day energy is: \(totalDayEnergy)")
                    let averageDayEnergy = totalDayEnergy / Double(dayEnergyArray.count)
//                    print("Average day energy is: \(averageDayEnergy)")
                    let newEnergy = Energy(context: moc)
                    newEnergy.value = Int16(averageDayEnergy)
                    newEnergy.energyType = energyType.stringValue
                    if let dateForArray = dayEnergyArray.first?.date {
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
        return dailyAveragesForWeekArray
    }
    
    
    
    
    var body: some View {
        if !weekArraySevenDays.isEmpty {
            Chart {
                ForEach(weekArraySevenDays, id: \.self) { item in
                    BarMark(
                        x: .value("Days", calendar.component(.weekday, from: item.date ?? Date.now)),
                        y: .value("Value", item.value)
                    )
//                    .lineStyle(StrokeStyle(lineCap: .round, lineJoin: .round))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
//            .chartXAxis {
//                AxisMarks(values: [1, 2, 3, 4, 5, 6, 7])
//            }
        } else {
            Text("No data for this week")
        }
    }
}


#Preview {
    @Environment(\.managedObjectContext) var moc
    return EnergyWeekChart(energyType: .emotional, energyValueArray: [Energy(context: moc)])
}
