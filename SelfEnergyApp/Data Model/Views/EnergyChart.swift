//
//  EnergyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 12.10.2023.
//
import Charts
import SwiftUI

struct EnergyChart: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var pickerChart: PickerChart
    var energyArray: [Energy]
    let energyType: EnergyType
    let calendar = Calendar.autoupdatingCurrent
    var date = Date()
    
    // Відфільтрований масив значень енергії протягом поточного дня
    var dayEnergyArray: [Energy] {
        energyArray.filter {
            calendar.dateComponents([.day, .month, .year], from: $0.date ?? Date.now) == calendar.dateComponents([.day, .month, .year], from: date)
        }
    }
    // Відфільтрований масив значень енергії протягом поточного тижня
    var weekEnergyArray: [Energy] {

        let dataForWeekArray = energyArray.filter {
            calendar.dateComponents([.weekOfYear, .year], from: $0.date ?? Date.now) == calendar.dateComponents([.weekOfYear, .year], from: date)
        }
        let daysOfWeek = Array(1...7)
        
        var dailyAveragesForWeekArray: [Energy] {
            var array: [Energy] = []
            for dayOfWeek in daysOfWeek {
                let dayEnergyArray = dataForWeekArray.filter { calendar.component(.weekday, from: $0.date ?? Date.now) == dayOfWeek}
                let totalDayEnergy = dayEnergyArray.reduce(0.0) { $0 + Double($1.value) }
                var averageDayEnergy: Double {
                    if dayEnergyArray.count != 0 {
                        totalDayEnergy / Double(dayEnergyArray.count)
                    } else {
                        totalDayEnergy / 1.0
                    }
                }
                let dateForArray = calendar.date(byAdding: .day, value: -dayOfWeek + 1, to: date)
                let newEnergy = Energy(context: moc)
                newEnergy.value = Int16(averageDayEnergy)
                newEnergy.energyType = energyType.rawValue
                newEnergy.date = dateForArray
                array.append(newEnergy)
                
            }
            return array
        }
        return dailyAveragesForWeekArray
    }
    
    
    
    
    var body: some View {
        switch pickerChart {
        case .day:
            if !dayEnergyArray.isEmpty {
                Chart {
                    ForEach(dayEnergyArray, id: \.self) { item in
                        LineMark(
                            x: .value("Hours", calendar.component(.hour, from: item.date ?? Date.now)),
                            y: .value("Value", item.value)
                        )
                        .lineStyle(StrokeStyle(lineCap: .round, lineJoin: .round))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 1, 2, 3, 4, 5])
                }
                .chartXAxis {
                    AxisMarks(values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])
                }
            } else {
                Text("No data for today")
            }
        case .week:
            if !weekEnergyArray.isEmpty {
                Chart {
                ForEach(weekEnergyArray, id: \.self) { item in
                    LineMark(
                        x: .value("Days", calendar.component(.weekday, from: item.date ?? Date.now)),
                        y: .value("Value", item.value)
                    )
                    .lineStyle(StrokeStyle(lineCap: .round, lineJoin: .round))
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4, 5])
            }
            .chartXAxis {
                AxisMarks(values: [1, 2, 3, 4, 5, 6, 7])
            }
        } else {
            Text("No data for today")
        }
        case .month:
            Text("Month")
        case .season:
            Text("Season")
        case .year:
            Text("Year")
        }
    }
}

#Preview {
    EnergyChart(pickerChart: .constant(.day), energyArray: [Energy()], energyType: .emotional)
}
