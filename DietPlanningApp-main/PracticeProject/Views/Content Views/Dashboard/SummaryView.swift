//
//  SummaryView.swift
//  PracticeProject
//
//  Created by Aditya Majumdar on 29/08/24.
//

import SwiftUI
import HealthKit
import SwiftData

struct WaveShapeSummary: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at the top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Draw a line to the bottom left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Draw a line to the bottom right corner, slightly above the bottom edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 50))
        // Draw a line back to the top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Move back to the bottom left corner to start the curve
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Add a curve to the bottom right corner, slightly above the bottom edge
        // Adjust control points to bring the curve's center more towards the center
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - 50),
                      control1: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.maxY + rect.height * 0.22), // Control point 1 moved towards center
                      control2: CGPoint(x: rect.maxX - rect.width * 0.35, y: rect.maxY + rect.height * 0.22)) // Control point 2 mirrored
        
        return path
    }
    
}
struct SummaryView: View {
    @Default(\.caloriesGoalText) var caloriesGoalText
    @Default(\.carbohydrateGoalText) var carbohydrateGoalText
    @Default(\.proteinGoalText) var proteinGoalText
    @Default(\.fatGoalText) var fatGoalText
    @Default(\.currentTheme) var currentTheme
    // convert the above string to double
    var caloriesGoal: Double {
        return Double(caloriesGoalText) ?? 0
    }
    var carbohydrateGoal: Double {
        return Double(carbohydrateGoalText) ?? 0
    }
    var proteinGoal: Double {
        return Double(proteinGoalText) ?? 0
    }
    var fatGoal: Double {
        return Double(fatGoalText) ?? 0
    }
    let screenSize: CGRect = UIScreen.main.bounds
    
    //@StateObject var healthKitManager = HealthKitManager.shared
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) var items: [Item]
    @State private var selectedHour: Date? = nil
    
    // This property aggregates today's nutritional data
    private var todaysNutrition: (calories: Double, fat: Double, carbs: Double, protein: Double) {
        let calendar = Calendar.current
        let todayItems = items.filter { calendar.isDateInToday($0.timestamp) }
        
        let totalCalories = todayItems.compactMap { $0.nfCalories }.reduce(0, +)
        let totalFat = todayItems.compactMap { $0.nfTotalFat }.reduce(0, +)
        let totalCarbs = todayItems.compactMap { $0.nfTotalCarbohydrate }.reduce(0, +)
        let totalProtein = todayItems.compactMap { $0.nfProtein }.reduce(0, +)
        return (totalCalories, totalFat, totalCarbs, totalProtein)
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack{
                    VStack(alignment: .center){
                        ZStack {
                            WaveShapeLog()
                                .opacity(0.4)
                                .frame(height: 170)
                                .shadow(color: .black, radius: 2, x: 0.0, y: 0.0)
                            
                            WaveShapeLog()
                                .opacity(0.75)
                                .frame(height: 170)
                                .offset(x: 0, y: -20.0)
                                .shadow(color: .black, radius: 4, x: 0.0, y: 0.0)
                        }                        
                        //   .ignoresSafeArea()
                        Spacer()
                        Spacer()
                        
                        NavigationLink(destination: DetailChartView(nutritionType: "Calories", nutriToday: todaysNutrition.calories, nutriUnit: "Cal", rawSelectedHour: $selectedHour)) {
                            nutriDisplayView(name: "Calories", unit: "Cal", nutriToday: todaysNutrition.calories, nutriConst: caloriesGoal, bgColor: Color("EmeraldL"), fgColors: [Color("EmeraldL"), Color("EmeraldR")])
                        }
                        Spacer()
                        NavigationLink(destination: DetailChartView(nutritionType: "Protein", nutriToday: todaysNutrition.protein, nutriUnit: "g", rawSelectedHour: $selectedHour)) {
                            nutriDisplayView(name: "Protein",  unit: "g",nutriToday: todaysNutrition.protein, nutriConst: proteinGoal, bgColor: Color("SeashoreL"), fgColors: [Color("SeashoreL"), Color("SeashoreR")])
                        }
                        Spacer()
                        NavigationLink(destination: DetailChartView(nutritionType: "Carbohydrate", nutriToday: todaysNutrition.carbs, nutriUnit: "g", rawSelectedHour: $selectedHour)) {
                            nutriDisplayView(name: "Carbohydrate",  unit: "g", nutriToday: todaysNutrition.carbs, nutriConst: carbohydrateGoal, bgColor: Color("VioletR"), fgColors: [Color("VioletL"), Color("VioletR")])
                        }
                        Spacer()
                        NavigationLink(destination: DetailChartView(nutritionType: "Fat", nutriToday: todaysNutrition.fat, nutriUnit: "g", rawSelectedHour: $selectedHour)) {
                            nutriDisplayView(name: "Fat",  unit: "g", nutriToday: todaysNutrition.fat, nutriConst: fatGoal, bgColor: Color("SunsetL"), fgColors: [Color("SunsetL"), Color("SunsetR")])
                        }
                        Spacer()
                        Spacer()
                        
                    }
                }
                
            }
                .navigationTitle("Summary")
                .ignoresSafeArea()
            
        }
    }
    
    private func nutriRingView(ringWidth: Double, pct: Double, dimension: Double, bgColor: Color, fgColors:[Color]) -> some View{
        return HStack (alignment: .center){
            RingView(ringWidth: ringWidth, percent: pct, backgroundColor: bgColor.opacity(0.33), foregroundColors: fgColors)
                .frame(width: dimension, height: dimension)
                
        }
        
    }
    
    private func nutriDisplayView(name: String, unit: String, nutriToday: Double, nutriConst: Double, bgColor: Color, fgColors: [Color]) -> some View {
        
        var iconName = "carrot.fill"
        switch name {
        case "Calories":
            iconName = "flame.fill"
        case "Protein":
            iconName = "fish.fill"
        default:
            iconName = "carrot.fill"
        }
        return HStack ( spacing: 2){
            
            VStack(alignment: .leading, spacing: 3) {
                
                VStack (alignment: .leading){
                    HStack {
                        Image(systemName: iconName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(bgColor)
                        Text(name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(bgColor)
                    }
                }
                Spacer()
                
                HStack (alignment: .firstTextBaseline ,spacing: 2){
                    Text("\(nutriToday, specifier: "%.0f") / \(nutriConst, specifier: "%.0f")")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .systemGray))
                        .fontWeight(.bold)
                    
                }
                
            }
                Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                        
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundColor(Color(uiColor: .systemGray3))
                            .alignmentGuide(.top) { d in d[.trailing] }
                        
                        Spacer()
                        
                        // Ring view
                nutriRingView(ringWidth: 14.4, pct: (nutriToday / nutriConst) * 100.00, dimension: 90, bgColor: bgColor, fgColors: fgColors)
                    }
                
        }
        .frame(maxWidth: screenSize.width * 0.85)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            
        )
    }
}

#Preview {
    SummaryView()
}
