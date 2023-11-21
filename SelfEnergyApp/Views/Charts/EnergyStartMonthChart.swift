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
    var currentDate: Date = Date.now
    // Масив усіх значень енергії певного виду
    let energyType: EnergyType
    var energyValueArray: [Energy]
    // Індекс, який повинен коригувати зміну місяця при гортанні графіку вправо-вліво
    let chartIndex: Int = 0
    // Місяць, для якого вираховується графік, з урахуванням індекса
    var monthForArray: Date {
        let components = calendar.dateComponents([.month, .year], from: Date())
        if let date = calendar.date(from: DateComponents(
            year: components.year,
            month: components.month! + chartIndex
            )
        ) {
            return date
        } else {
            return Date()
        }
    }
    
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
    
    var body: some View {
        if !monthArray.isEmpty {
            Chart {
                ForEach(monthArray, id: \.self) { item in
                    BarMark(
                        x: .value("Days", item.date),
                        y: .value("Value", item.value)
                    )
                }
            }
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
        return EnergyStartMonthChart(energyType: .emotional, energyValueArray: example)
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}

