//
//  AddDataView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 17.09.2023.
//

import SwiftUI

struct AddDataView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var value: Int = 2
    @State private var date: Date = Date.now
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
                
                DatePicker("Date", selection: $date)
                
                Button("Save") {
                    print("\(value)")
                }
            }
            .navigationTitle("Add \(energyType.stringValue) data")
            .toolbar {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
    
    func save() {
        let energyData = Energy(context: moc)
        energyData.value = Int16(value)
        energyData.date = date
        energyData.energyType = energyType
        
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

struct AddDataView_Previews: PreviewProvider {
    static var previews: some View {
        AddDataView(energyType: .physical)
    }
}
