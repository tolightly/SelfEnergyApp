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
    var currentDate: Date = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: Date()) ?? Date()
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    
    // Індекс для зміщення наступного графіку
    @Binding var index: Int
    var offsetMonthIndex: Int { 6 * index }
    var offsetSecondIndex: Double { 60 * 60 * 24 * 183 * Double(index) }
    
    
    var startDate: Date {
        calendar.date(byAdding: .month, value: (-6 + offsetMonthIndex), to: currentDate) ?? currentDate - (60 * 60 * 24 * 183 + offsetSecondIndex)
    }
    var endDate: Date {
        calendar.date(byAdding: .month, value: (0 + offsetMonthIndex), to: currentDate) ?? currentDate + offsetSecondIndex
    }
    
    // Масив значень для графіку за останні 6 місяців
    var halfYearArray: [Energy] {

        let dataForHalfYearArray = energyValueArray.filter { $0.date >= startDate && $0.date <= endDate }
        
        let numbersOfWeekComponentsArray = Array(Set(dataForHalfYearArray.compactMap {
            Calendar.current.component(.weekOfYear, from: $0.date)
        })).sorted()
        
        var weekAveragesForHalfYearArray: [Energy] {
            var array: [Energy] = []
            
            for index in numbersOfWeekComponentsArray {
                let weekEnergyArray = dataForHalfYearArray.filter { calendar.component(.weekOfYear, from: $0.date) == index }

                if !weekEnergyArray.isEmpty {
                    let totalWeekEnergy = weekEnergyArray.reduce(0) { $0 + Double($1.value) }
                    let averageWeekEnergy = totalWeekEnergy / Double(weekEnergyArray.count)
//                    var dateForArray: Date {
//                        if let dateForArray = weekEnergyArray.first?.date {
//                            let components = calendar.dateComponents([.year, .month, .weekOfYear], from: dateForArray)
//                            let formattedDateForArray = calendar.date(from: DateComponents (
//                                year: components.year,
//                                month: components.month,
//                                day: 4,
//                                weekOfYear: components.weekOfYear)
//                            ) ?? currentDate
//                                return formattedDateForArray
//                        }
//                            else {
//                            return currentDate
//                        }
//                    }
                    var dateForArray: Date {
                        if let date = weekEnergyArray.first?.date {
                            let dateForArray = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
                            return dateForArray
                        } else {
                            return currentDate
                        }
                    }
                        
                    let newEnergy = Energy(value: averageWeekEnergy, date: dateForArray, energyType: energyType)
                    array.append(newEnergy)
                }
            }
            return array
        }
        return weekAveragesForHalfYearArray
    }
    
    // Відображення порожнього массиву
    var emptyArray: [Energy] {
        let newEnergy = Energy(value: 0, date: currentDate, energyType: energyType)
        return [newEnergy]
    }
    
    
    var body: some View {
        VStack {
            Text("\(startDate.formatted(date: .long, time: .omitted) ) - \(endDate.formatted(date: .long, time: .omitted))")
            
            Chart {
                ForEach(halfYearArray.isEmpty ? emptyArray : halfYearArray) { item in
                    BarMark(
                        x: .value("Weeks", item.date),
                        y: .value("Value", item.value),
                        width: 9
                    )
                }
            }
            .frame(width: 400, height: 300)
            .chartYScale(domain: [0, 5])
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

        let example = [
            Energy(value: 1, date: Date.now - 6 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 2, date: Date.now - 5 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 3, date: Date.now - 4 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 4, date: Date.now - 3 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 5, date: Date.now - 2 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 2, date: Date.now - 1 * 24 * 60 * 60, energyType: .emotional),
            Energy(value: 4, date: Date.now - 0 * 24 * 60 * 60, energyType: .emotional)
            ]
        return EnergyHalfYearChart(energyType: .emotional, energyValueArray: example, index: .constant(0))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}

