//
//  LastNotesView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 20.10.2023.
//
import SwiftData
import SwiftUI

struct LastNotesView: View {
    @Environment(\.modelContext) var modelContext
    let energyArray: [Energy]
    
    var body: some View {
        List {
            ForEach(energyArray) { energy in
                HStack {
                    Text(energy.value.formatted())
                    Spacer()
                    Text(energy.date.formatted(date: .numeric, time: .shortened))
                    Spacer()
                    Text(energy.energyType)
                }
            }
            .onDelete(perform: deleteItem)
        }
        .padding()
        .toolbar {
            EditButton()
        }
        .navigationTitle("Energy diary")
    }
    
    func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.compactMap { energyArray[$0] }.forEach { modelContext.delete($0) }
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
            return EnergyDayChart(energyValueArray: example)
                .modelContainer(container)
        } catch {
            fatalError("Failed to create model container.")
        }
}
