//
//  EnergyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 06.10.2023.
//

import Charts
import SwiftUI

struct EnergyChart: View {
    @Environment(\.managedObjectContext) var moc

    var energyValueArray: [Energy]
    var pickerChart: PickerChart
    var arrayForChart: [Energy] {
        createDayArray(date: Date.now, energyValueArray: energyValueArray)
    }
    
    var body: some View {
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
            AxisMarks(values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
        }
    }
}

func createDayArray(date: Date, energyValueArray: [Energy]) -> [Energy] {
    let calendar = Calendar.autoupdatingCurrent
    let day: DateComponents = calendar.dateComponents([.day], from: date)
    // Масив значень показників вибраної енергії за вказаний день
    let energyValueForThisDayArray = energyValueArray.filter {
        calendar.dateComponents([.day], from: $0.date ?? Date.now) == day
    }
    return energyValueForThisDayArray
}

//#Preview {
//    EnergyChart(energyValueArray: [Energy], pickerChart: .day)
//}
