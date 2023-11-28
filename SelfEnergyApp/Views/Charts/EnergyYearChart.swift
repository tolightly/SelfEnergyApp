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
    var currentDate: Date = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: Date()) ?? Date()
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    
    @Binding var index: Int
    var indexOffset: Double { 60 * 60 * 24 * 365 * Double(index) }
    
    var startDate: Date {
        calendar.date(byAdding: .year, value: -1 + index, to: currentDate) ?? currentDate + (60 * 60 * 24 * 365) + indexOffset
    }
    
    var endDate: Date {
        calendar.date(byAdding: .year, value: index, to: currentDate) ?? currentDate - indexOffset
    }

    // Масив значень для графіку, якщо хочемо отримати відомості за останній рік
    var yearArray: [Energy] {
        
        let dataForYearArray = energyValueArray.filter { $0.date >= startDate && $0.date <= endDate }
        
        let numbersOfMonthComponentsArray = Array(Set(dataForYearArray.compactMap { calendar.component(.month, from: $0.date)})).sorted()
        
        var monthlyAveragesForYearArray: [Energy] {
            var array: [Energy] = []
            
            for index in numbersOfMonthComponentsArray {
                let monthEnergyArray = dataForYearArray.filter { calendar.component(.month, from: $0.date) == index }
                
                if !monthEnergyArray.isEmpty {
                    let totalMonthEnergy = monthEnergyArray.reduce(0) { $0 + Double($1.value) }

                    let averageMonthEnergy = totalMonthEnergy / Double(monthEnergyArray.count)

                    var dateForArray: Date {
                        if let dateForArray = monthEnergyArray.first?.date {
                            let components = calendar.dateComponents([.year, .month], from: dateForArray)

                            let formattedDateForArray = calendar.date(from: DateComponents (
                                year: components.year,
                                month: components.month
                                )
                            ) ?? currentDate
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
            return array
        }
        return monthlyAveragesForYearArray
    }
    
    // Відображення порожнього массиву
    var emptyArray: [Energy] {
        let newEnergy = Energy(value: 0, date: startDate, energyType: energyType)
        let newEnergy2 = Energy(value: 0, date: endDate, energyType: energyType)
        return [newEnergy, newEnergy2]
    }
    
    
    var body: some View {
        VStack {
            Text("\(startDate.formatted(date: .long, time: .omitted)) - \(endDate.formatted(date: .long, time: .omitted))")
            
            Chart {
                ForEach(yearArray.isEmpty ? emptyArray : yearArray) { item in
                    BarMark(
                        x: .value("Months", item.date),
                        y: .value("Value", item.value),
                        width: 15
                    )
                }
            }
            .frame(width: 400, height: 300)
            .chartYScale(domain: [0, 5])
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXScale(domain: [startDate, endDate])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().month(.abbreviated),
                    values: .automatic(desiredCount: 5)
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
        return EnergyYearChart(energyType: .emotional, energyValueArray: example, index: .constant(0))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
