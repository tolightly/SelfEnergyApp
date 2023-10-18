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
    
    @State private var pickerChart: PickerChart = .day
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
// Загальне ScrollView
            ScrollView {
                VStack {
// Повинно відображатися поточне значення енергії, яке буде якось вираховуватись
                    Text("75%")
                        .font(.largeTitle)
// Picker для вибору часового проміжку графіку
                    Picker("Picker", selection: $pickerChart) {
                        Text("Day").tag(PickerChart.day)
                        Text("Week").tag(PickerChart.week)
                        Text("Month").tag(PickerChart.month)
                        Text("3 month").tag(PickerChart.season)
                        Text("Year").tag(PickerChart.year)
                    }
                    .pickerStyle(.segmented)
                   
 // Chart View, яке відображає різні графіки, залежно від значення пікера
                    switch pickerChart {
                    case .day:
                        EnergyDayChart(energyValueArray: energyArrayForChart)
                    case .week:
                        EnergyWeekChart(energyType: energyType, energyValueArray: energyArrayForChart)
                    case .month:
                        EnergyMonthChart(energyType: energyType, energyValueArray: energyArrayForChart)
                    case .season:
                        EnergySeasonChart(energyType: energyType, energyValueArray: energyArrayForChart)
                    case .year:
                        EnergyYearChart(energyType: energyType, energyValueArray: energyArrayForChart)
                    }
                    
// Поради щодо даного виду енегрії
                    GroupBox {
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                    }
                    
// Історія записів вибраного виду енергії
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
