//
//  EnergyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 06.10.2023.
//

import Charts
import SwiftData
import SwiftUI

struct EnergyDayChart: View {
    var energyType: EnergyType
    // Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    // Значення, на яке буде зміщуватись дата, для якої будується графік
    @Binding var index: Int
    // Вибраний елемент на графіку
    @State private var selectedDate: Date? = nil
    
    let calendar = Calendar.current
    // Дата, для якої будується графік
    var dateForChart: Date { calendar.date(byAdding: .day, value: index, to: Date.now) ?? Date.now }
    
    var startDate: Date {
        calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateForChart) ?? dateForChart
    }
    var endDate: Date {
        calendar.date(bySettingHour: 23, minute: 59, second: 59, of: dateForChart) ?? dateForChart
    }
    // Відфільтрований масив значень енергії протягом поточного дня
    var arrayForChart: [Energy] {
        energyValueArray.filter {
            Calendar.current.dateComponents([.day, .month, .year], from: $0.date) == Calendar.current.dateComponents([.day, .month, .year], from: dateForChart)
        }
    }
    var emptyArray: [Energy] {
        let newEnergy = Energy(value: 0, date: dateForChart, energyType: energyType)
        return [newEnergy]
    }
    
    var averageDayValue: Double {
        if arrayForChart.isEmpty {
            return 0
        } else {
            let totalDayValue = arrayForChart.reduce(0) { $0 + Double($1.value) }
            return totalDayValue / Double(arrayForChart.count)
        }
    }

    
    var body: some View {
            VStack {
                Text(dateForChart.formatted(date: .complete, time: .omitted))
                
                Chart {
                    ForEach(arrayForChart.isEmpty ? emptyArray : arrayForChart, id: \.self) { item in
                        
                        if let selectedDate, calendar.component(.hour, from: selectedDate) == calendar.component(.hour, from: item.date) {
                            RuleMark(
                                x: .value("Hours", item.date),
                                yStart: .value("Value", 5),
                                yEnd: .value("Value", item.value)
                            )
                            .foregroundStyle(.gray)
                            .annotation(position: .top) {
                                GroupBox {
                                    VStack {
                                        Text("Time: \(item.date.formatted(date: .omitted, time: .shortened))")
                                        Text("Value: \(item.value.formatted())")
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                        
                        BarMark(
                            x: .value("Hours", item.date),
                            y: .value("Value", item.value),
                            width: 15
                        )
                    }
                    if averageDayValue != 0 {
                        RuleMark(y: .value("Average value", averageDayValue))
                            .foregroundStyle(.red)
                            .annotation {
                                Text("\(averageDayValue.formatted())")
                            }
                    }
                }
                .frame(width: 400, height: 300)
                .chartYScale(domain: [0, 5])
                .chartXScale(domain: [startDate, endDate])
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartXAxis {
                    AxisMarks(
                        format: Date.FormatStyle().hour(.conversationalDefaultDigits(amPM: .abbreviated)),
                        values: .automatic(desiredCount: 6))
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
                                
                                selectedDate = date
                            }
                            .gesture(
                                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                                    .onEnded { value in
                                        if value.translation.width > 0 {
                                                index -= 1
                                        } else if value.translation.width < 0 {
                                            if index < 0 {
                                                index += 1
                                            }
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

        let example = Energy(value: 3, date: Date.now, energyType: .emotional)
        return EnergyDayChart(energyType: .emotional, energyValueArray: [example], index: .constant(0))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
