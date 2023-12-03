//
//  EnergyStartMonthChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 12.11.2023.
//
import Charts
import SwiftData
import SwiftUI

struct EnergyStartMonthChart: View {
    let calendar = Calendar.current
    // Дата, для якої будується графік
    var currentDate: Date = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: Date()) ?? Date()
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    // Індекс, який повинен коригувати зміну місяця при гортанні графіку вправо-вліво
    @Binding var index: Int
    @State private var selectedDate: Date? = nil
    // Місяць, для якого вираховується графік, з урахуванням індекса
    var monthForArray: Date { calendar.date(byAdding: .month, value: index, to: currentDate) ?? currentDate }
    
    var countDaysInMonth: Range<Int>? { return Calendar.current.range(of: .day, in: .month, for: monthForArray)
    }
    
    var finalNumberDayInMonthForAxis: Int { return countDaysInMonth?.upperBound ?? 31
    }
    
    var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.month, .year], from: monthForArray)
        return calendar.date(from: components)!
    }
    
    var lastDayOfMonth: Date {
        var components = calendar.dateComponents([.year, .month, .day], from: monthForArray)
        components.month! += 1
        components.day! = 1
        components.day! -= 1
        return calendar.date(from: components)!
    }
    
    // Масив значень для графіку, якщо хочемо отримати відомості за місяць
    var monthArray: [Energy] {
        let dataForMonthArray = energyValueArray.filter { calendar.dateComponents([.month, .year], from: $0.date) == calendar.dateComponents([.month, .year], from: monthForArray) }

        var dailyAveragesForWeekArray: [Energy] {
            var array: [Energy] = []
            
            for index in countDaysInMonth! {
                let dayEnergyArray = dataForMonthArray.filter {
                    calendar.component(.weekday, from: $0.date) == index
                }
                
                if !dayEnergyArray.isEmpty {
                    let totalDayEnergy = dayEnergyArray.reduce(0) { $0 + Double($1.value) }
                    let averageDayEnergy = totalDayEnergy / Double(dayEnergyArray.count)

                    var dateForArray: Date {
                        if let dateForArray = dayEnergyArray.first?.date {
                            let formattedDateForArray = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateForArray) ?? currentDate
                                return formattedDateForArray
                        } else {
                            return currentDate
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
        let newEnergy = Energy(value: 0, date: currentDate, energyType: energyType)
        return [newEnergy]
    }
    
    var averageValue: Double {
        if monthArray.isEmpty {
            return 0
        } else {
            let totalValue = monthArray.reduce(0) { $0 + $1.value }
            return totalValue / Double(monthArray.count)
        }
    }
    
    var body: some View {
        VStack {
            Text("\(monthForArray.formatted(Date.FormatStyle().month(.wide))) \(monthForArray.formatted(Date.FormatStyle().year()))")
            
            Chart {
            ForEach(monthArray.isEmpty ? emptyArray : monthArray) { item in
                
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
                            width: 12
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
                .chartXScale(domain: [firstDayOfMonth, lastDayOfMonth])
                .chartXAxis {
                    AxisMarks(
                        format: Date.FormatStyle().day(.defaultDigits),
                        values: .automatic(desiredCount: 5)
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
        return EnergyStartMonthChart(energyType: .emotional, energyValueArray: example, index: .constant(0))
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}

