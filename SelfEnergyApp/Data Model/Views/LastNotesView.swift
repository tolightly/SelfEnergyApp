//
//  LastNotesView.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 20.10.2023.
//

import SwiftUI

struct LastNotesView: View {
    @Environment(\.managedObjectContext) var moc
    let energyArray: [Energy]
    
    var body: some View {
        List {
            ForEach(energyArray) { energy in
                HStack {
                    Text("\(energy.value)")
                    Spacer()
                    Text(energy.date?.formatted(date: .numeric, time: .shortened) ?? "Error with fetched date")
                    Spacer()
                    Text(energy.unwrappedEnergyType?.rawValue ?? "Error with fetch energyType")
                }
            }
            .onDelete(perform: deleteItem)
        }
        .padding()
        .toolbar {
            EditButton()
        }
    }
    
    func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.compactMap { energyArray[$0] }.forEach { moc.delete($0) }
            try? moc.save()
        }
    }
}


#Preview {
    @Environment(\.managedObjectContext) var moc
    return LastNotesView(energyArray: [Energy(context: moc)])
}
