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
    @State private var selectedDate: Date? = nil
    
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
        let newEnergy = Energy(value: 0, date: endDate, energyType: energyType)
        return [newEnergy]
    }
    
    var averageValue: Double {
        if halfYearArray.isEmpty {
            return 0
        } else {
            let totalValue = halfYearArray.reduce(0) { $0 + $1.value }
            return totalValue / Double(halfYearArray.count)
        }
    }
    
    var body: some View {
        VStack {
            Text("\(startDate.formatted(date: .long, time: .omitted) ) - \(endDate.formatted(date: .long, time: .omitted))")
            
            Chart {
                ForEach(halfYearArray.isEmpty ? emptyArray : halfYearArray) { item in
                    
                    if let selectedDate, calendar.component(.weekOfYear, from: selectedDate) == calendar.component(.weekOfYear, from: item.date) {
                        RuleMark(
                            x: .value("Day", item.date),
                            yStart: .value("Value", 5),
                            yEnd: .value("Value", item.value)
                        )
                        .foregroundStyle(.gray)
                        .annotation(position: .top) {
                            GroupBox {
                                VStack {
                                    Text("Date: \(item.date.formatted(date: .abbreviated, time: .omitted))")
                                    Text("Value: \(String(format: "%.2f", item.value))")
                                }
                                .font(.caption)
                            }
                        }
                    }
                    
                    BarMark(
                        x: .value("Weeks", item.date),
                        y: .value("Value", item.value),
                        width: 9
                    )
                }
                
                if averageValue != 0 {
                    RuleMark(y: .value("Average value", averageValue))
                        .foregroundStyle(.red)
                        .annotation {
                            Text(String(format: "%.2f", averageValue))
                        }
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
                    values: .automatic(desiredCount: 6)
                )
            }
            .chartOverlay { chartProxy in
                GeometryReader { geometryProxy in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            let currentX = location.x - geometryProxy[chartProxy.plotFrame!].origin.x
                            guard currentX <= chartProxy.plotSize.width else { return }
                            guard let date = chartProxy.value(atX: currentX, as: Date.self) else { return }
                            selectedDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                                .onEnded { value in
                                    if value.translation.width > 0 {
                                        index -= 1
                                    } else if value.translation.width < 0 {
                                        index += 1
                                    }
                                }
                        )
                }
            }
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

