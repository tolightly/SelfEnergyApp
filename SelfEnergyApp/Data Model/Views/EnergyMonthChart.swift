//
//  EnergyMonthChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 11.10.2023.
//

import Charts
import SwiftUI

struct EnergyMonthChart: View {
    // Дата, для якої будується графік
    var date: Date = Date.now
    // Масив усіх значень енергії певного виду
    var energyValueArray: [Energy]
    // Відфільтрований масив значень енергії протягом поточного дня
    var arrayForChart: [Energy] {
        energyValueArray.filter {
            Calendar.autoupdatingCurrent.dateComponents([.month, .year], from: $0.date ?? Date.now) == Calendar.autoupdatingCurrent.dateComponents([.month, .year], from: date)
        }
    }
    func daysInMonth(date: Date) -> [Int] {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month], from: date)

        if let firstDayOfMonth = calendar.date(from: components) {
            let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) ?? 1..<31
            return Array<Int>(range)
        } else {
            return []
        }
    }
    
    
    var body: some View {
        if !arrayForChart.isEmpty {
            Chart {
                ForEach(arrayForChart, id: \.self) { item in
                    LineMark(
                        x: .value("Days", Calendar.autoupdatingCurrent.component(.hour, from: item.date ?? Date.now)),
                        y: .value("Value", item.value)
                    )
                    .lineStyle(StrokeStyle(lineCap: .round, lineJoin: .round))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXAxis {
                AxisMarks(values: daysInMonth(date: Date.now))
            }
        } else {
            Text("No data for today")
        }
    }
}


#Preview {
    @Environment(\.managedObjectContext) var moc
    return EnergyMonthChart(energyValueArray: [Energy(context: moc)])
}
