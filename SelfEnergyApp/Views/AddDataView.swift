//
//  AddDataView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 17.09.2023.
//
import CoreData
import SwiftData
import SwiftUI

struct AddDataView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var value: Int = 2
    @State private var selectedDate: Date = Date.now

    var energyType: EnergyType
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Value", selection: $value) {
                    ForEach(1..<6) { index in
                        Text("\(index)").tag(index)
                    }
                }
                .pickerStyle(.segmented)
                
                DatePicker(
                    "Date",
                    selection: Binding<Date>(
                        get: { setMinuteToZero(date: self.selectedDate) },
                        set: { newDate in
                            self.selectedDate = setMinuteToZero(date: newDate)
                        }
                    )
                )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Button("Save") {
                    save()
                }
            }
            .navigationTitle("Add \(energyType.rawValue) data")
            .toolbar {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
    
    func save() {
        let energyData = Energy(value: Double(value), date: setMinuteToZero(date: selectedDate), energyType: energyType)
        modelContext.insert(energyData)
        try? modelContext.save()
        dismiss()
    }
    
    func setMinuteToZero(date: Date) -> Date {
        let calendar = Calendar.current
        let newMinute = calendar.component(.minute, from: date)
        
        if newMinute != 0 {
            let modifiedDate = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: 0, second: 0, of: date)
            
            if let modifiedDate {
                return modifiedDate
            } else {
                print("Error with modified date")
                return Date.now
            }
        }
        else {
            return date
        }
    }
}

struct AddDataView_Previews: PreviewProvider {
    static var previews: some View {
        AddDataView(energyType: .physical)
    }
}
