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
    
    @Binding var index: Int
    @State private var selectedDate: Date? = nil
    // Дата, для якої будується графік
    var dateForChart: Date { Calendar.current.date(byAdding: .day, value: index * 7, to: date) ?? date }

    
    var firstDayOfWeek: Date {
        let components = calendar.dateComponents([.weekOfYear, .year], from: dateForChart)
        
        let date = calendar.date(from: DateComponents(
            year: components.year,
            weekday: 2,
            weekOfYear: components.weekOfYear)
        )
        return date ?? dateForChart
    }

// Відфільтрований масив значень енергії протягом поточного тижня, з початку тижня
    var weekArrayFromStart: [Energy] {
        let dataForWeekArray = energyValueArray.filter {
            calendar.dateComponents([.weekOfYear, .year], from: $0.date) == calendar.dateComponents([.weekOfYear, .year], from: dateForChart)
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
    
    // Відображення порожнього массиву
    var emptyArray: [Energy] {
        let newEnergy = Energy(value: 0, date: date, energyType: energyType)
        return [newEnergy]
    }
    
    var averageValue: Double {
        if weekArrayFromStart.isEmpty {
            return 0
        } else {
            let totalValue = weekArrayFromStart.reduce(0) { $0 + $1.value }
            return totalValue / Double(weekArrayFromStart.count)
        }
        
    }
    
    var body: some View {
        VStack {
            Text("\(firstDayOfWeek.formatted(date: .long, time: .omitted)) - \(firstDayOfWeek.advanced(by: 60 * 60 * 23 * 7).formatted(date: .long, time: .omitted))")
            
            Chart {
                ForEach(weekArrayFromStart.isEmpty ? emptyArray : weekArrayFromStart, id: \.self) { item in
                    
                    if let selectedDate, calendar.component(.day, from: selectedDate) == calendar.component(.day, from: item.date) {
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
                                    Text("Value: \(item.value.formatted())")
                                }
                                .font(.caption)
                            }
                        }
                    }
                    
                    BarMark(
                        x: .value("Days", item.date),
                        y: .value("Value", item.value),
                        width: 15
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
            .chartXScale(domain: [firstDayOfWeek, firstDayOfWeek.advanced(by: 60 * 60 * 24 * 7)])
            .chartXAxis {
                AxisMarks(
                    format: Date.FormatStyle().weekday(.narrow),
                    values: .automatic(desiredCount: 7)
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
        return EnergyStartWeekChart(energyType: .emotional, energyValueArray: example, index: .constant(0))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
