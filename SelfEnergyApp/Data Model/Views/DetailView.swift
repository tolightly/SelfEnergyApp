//
//  DetailView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 11.09.2023.
//
import Charts
import SwiftUI

struct DetailView: View {

    var energyType: EnergyType
    let example = EnergyValue.example
    
    @State private var pickerChart: PickerChart = .week
    @State private var isShowingAddView = false
    
    @FetchRequest var energyArray: FetchedResults<Energy>
    
    init(energyType: EnergyType) {
        self.energyType = energyType
        _energyArray = FetchRequest(
            sortDescriptors: [SortDescriptor(\.date, order: .forward)],
            predicate: NSPredicate(format: "energyType == %@", energyType.rawValue))
    }
    
    var energyArrayForChart: [Energy] {
        energyArray.compactMap { $0 }
    }
    
    var body: some View {
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
                    
                    EnergyChart(energyValueArray: energyArrayForChart, pickerChart: pickerChart)
                    
                    GroupBox {
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    }
                    
                    GroupBox("Last Notes") {
                        ForEach(energyArray) { energy in
                            HStack {
                                Text("\(energy.value)")
                                Spacer()
                                Text(energy.date?.formatted(date: .numeric, time: .shortened) ?? "Error with fetched date")
                                Spacer()
                                Text(energy.unwrappedEnergyType?.rawValue ?? "Error with fetch energyType")
                            }
                        }
                    }
                }
            }
            .navigationTitle(energyType.stringValue)
            .toolbar {
                Button {
                    // Edit values
                } label: {
                    Text("Edit")
                }
                
                Button {
                    isShowingAddView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isShowingAddView, content: {
                    AddDataView(energyType: energyType)
            })
            .padding()
        }
}

enum PickerChart {
    case day, week, month, season, year
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(energyType: .physical)
    }
}
