//
//  DetailView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 11.09.2023.
//
import Charts
import SwiftUI

struct DetailView: View {
    
    enum PickerChart {
        case day, week, month, season, year
    }
    
    let example = EnergyValue.example
    
    @State private var pickerChart: PickerChart = .week
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("75%")
                        .font(.largeTitle)
                    Picker("Picker", selection: $pickerChart) {
                        Text("Day").tag(PickerChart.day)
                        Text("Week").tag(PickerChart.week)
                        Text("Month").tag(PickerChart.month)
                        Text("3 month").tag(PickerChart.season)
                        Text("Year").tag(PickerChart.year)
                    }
                    .pickerStyle(.segmented)
                    
                    Chart {
                        ForEach(example, id: \.self) { item in
                            LineMark(
                                x: .value("Days", item.date),
                                y: .value("Value", item.value)
                            )
                            .lineStyle(StrokeStyle(lineCap: .round, lineJoin: .round))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [0, 1, 2, 3, 4, 5])
                    }
                    GroupBox {
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    }
                    
                    GroupBox("Last Notes") {
                        HStack {
                            Text(EnergyValue.example[0].date.formatted(date: .numeric, time: .shortened))
                            Spacer()
                            Text(EnergyValue.example[0].value.formatted(.number))
                            Spacer()
                            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry.")
                        }
                    }
                }
            }
            .navigationTitle("Physical")
            .toolbar {
                Button {
                    // Edit values
                } label: {
                    Text("Edit")
                }
                
                Button {
                    //Add new value
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding()
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
