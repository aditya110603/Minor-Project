//
//  NutritionSummaryView.swift
//  PracticeProject
//
//  Created by Aditya Majumdar on 29/08/24.
//

import SwiftUI
import SwiftData

struct NutritionSummaryView: View {
    @EnvironmentObject var nutriVM: NutritionViewModel
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) var items: [Item]
    
    var nutrientType: NutrientType
    var name: String
    @State private var selectedHour: Date? = nil
    @State private var selectedDate: Date? = nil
    
    var body: some View {
        let nutriToday = nutriVM.totalIntakeToday(nutrientType: nutrientType, items: items)
        NavigationStack {
            
            List {
                VStack (alignment: .leading){
                    Text("Today")
                        .font(.headline)
                        .fontWeight(.semibold)
                    NavigationLink (destination: DetailDailyChartView(nutritionType: name, nutrientType: nutrientType, nutriToday: nutriToday, rawSelectedHour: $selectedHour)){
                        SimpleDailyChartView(viewModel: nutriVM, nutrientType: nutrientType, name: name)
                    }
                    .isDetailLink(false)
                }
                .padding(7)
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .padding(5)
                )
                
                VStack (alignment: .leading){
                    Text("Past 7 Days")
                        .font(.headline)
                        .fontWeight(.semibold)
                    NavigationLink (destination: DetailWeeklyChart(vm: nutriVM, name: name, rawSelectedDate: $selectedDate, nutrientType: nutrientType)){
                        SimpleWeeklyChartView(viewModel: nutriVM, nutrientType: nutrientType, name: name)
                    }
                    .isDetailLink(false)
                }
                .padding(7)
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .padding(5)
                )
                
                VStack (alignment: .leading){
                    Text("Past Month")
                        .font(.headline)
                        .fontWeight(.semibold)
                    NavigationLink (destination: DetailMonthlyChart(vm: nutriVM, name: name, rawSelectedDate: $selectedDate, nutrientType: nutrientType)){
                        SimpleMonthlyChartView(viewModel: nutriVM, nutrientType: nutrientType, name: name)
                   }
                .isDetailLink(false)
                }
                .padding(7)
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .padding(5)
                )
                
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle(name)
        }
        
    }
}

