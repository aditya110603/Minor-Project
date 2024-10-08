//
//  MonthlyChartView.swift
//  PracticeProject
//
//  Created by Aditya Majumdar on 20/08/24.
//


import SwiftUI
import SwiftData
import Charts

// View Data for Past 30 days

struct MonthlyChartView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) var items: [Item]
    @Default(\.currentTheme) var currentTheme
    var nutrientType: NutrientType
    let screenSize = UIScreen.main.bounds.size
    var name: String
    
    var body: some View {
        
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        // Adjust startDate to the start of the day in the current calendar
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        
        // Filter items to include all from the start of the startDate
        let filteredItems = items.filter { $0.timestamp >= startOfDay && $0.timestamp <= Date() }
        
        VStack {
            Chart {
                ForEach(viewModel.nutrientIntakeByDay(nutrientType: nutrientType, items: filteredItems), id: \.date) { intake in
                    BarMark(
                        x: .value("Date", intake.date, unit: .day),
                        y: .value("Calories", intake.totalIntake)
                    )
                    .foregroundStyle(colorFromString(currentTheme))
                }
            }
            
            
        }
        .padding()
    }
}

