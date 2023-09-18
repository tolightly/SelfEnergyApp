//
//  DynamicEnergyChart.swift
//  SelfEnergyApp
//
//  Created by Denys Nazymok on 20.09.2023.
//

//import SwiftUI
//
//struct DynamicEnergyChart: View {
//
//        @FetchRequest var dataForChart: FetchedResults<Energy>
//        
//    init(currentPickerChart: PickerChart, energyType: EnergyType) {
//            switch currentPickerChart {
//            case .day:
//                return  _dataForChart = FetchRequest<Energy>(sortDescriptors: [], predicate: "energyType == %@", energyType.rawValue  )
//            case .week:
//            case .month:
//            case .season:
//            case .year:
//            }
//           
//        }
//    
//    
//    
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    DynamicEnergyChart()
//}
