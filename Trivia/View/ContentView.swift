//
//  ContentView.swift
//  Trivia
//
//  Created by Kiran Brahmatewari on 3/28/25.

import SwiftUI

struct ContentView: View {
    @State private var numberOfQuestions: Int = 10
    @State private var sliderValue: Float = 0.0
    @State private var selectedCategory: String = "Any Category"
    @State private var selectedDifficulty: String = "Any Difficulty"
    @State private var selectedType: String = "Any Type"
    @State private var selectedDuration: String = "30 seconds"
    @State var showGame: Bool = false

    private let difficulties: [String] = ["Any Difficulty", "Easy", "Medium", "Hard"]
    private let durations: [String] = ["30 seconds", "60 seconds", "120 seconds", "300 seconds", "1 hour"]
    
    private let typeMap: [String: String] = [
        "Any Type" : "",
        "Multiple Choice" : "multiple",
        "True/False" : "boolean"
    ]
    
    private let categoryMap: [String: Int] = [
        "Any Category" : -1,
        "General Knowledge" : 9,
        "Entertainment: Books" : 10,
        "Entertainment: Film" : 11,
        "Entertainment: Music" : 12,
        "Entertainment: Musicals & Theatres" : 13,
        "Entertainment: Television" : 14,
        "Entertainment: Video Games" : 15,
        "Entertainment: Board Games" : 16,
        "Entertainment: Comics" : 29,
        "Entertainment: Japanese Anime & Manga" : 31,
        "Entertainment: Cartoon & Animations" : 32,
        "Science & Nature" : 17,
        "Science: Computers" : 18,
        "Science: Mathematics" : 19,
        "Science: Gadgets" : 30,
        "Mythology" : 20,
        "Sports" : 21,
        "Geography" : 22,
        "History" : 23,
        "Politics" : 24,
        "Art" : 25,
        "Celebrities" : 26,
        "Animals" : 27,
        "Vehicles" : 28
    ]
            
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                settings
                startButton
            }
            .navigationBarTitle("Trivia Game", displayMode: .large)
            .toolbarBackground(Constants.backgroundColor, for: .navigationBar)
            .background(Constants.backgroundColor)
        }
        .onAppear {
            // Navigation bar (i.e. Trivia Game) appearance
            let appearance = UINavigationBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor(Constants.backgroundColor)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var startButton: some View {
        Button(action: {
            showGame = true
        }) {
            Text("Start Trivia")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Constants.buttonColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding()
        }
        .background(.clear)
        .navigationDestination(isPresented: $showGame) {
            GameView(
                numberOfQuestions: Int(numberOfQuestions),
                category: categoryURL(),
                difficulty: difficultyURL(),
                type: typeURL(),
                duration: convertDuration(selectedDuration)
            )
        }
    }
    
    @ViewBuilder
    private var settings: some View {
        Form {
            Section(header: Text("Settings")) {
                Stepper(value: $numberOfQuestions, in: 1...50, step: 1) {
                    TextField("Number of Questions", value: $numberOfQuestions, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .tint(Constants.accentColor)
                }
                .foregroundColor(Constants.foregroundColor)
                                
                Picker("Category", selection: $selectedCategory) {
                    // Keeps categories in the same order; needed since dicts are unordered
                    ForEach(Array(categoryMap.keys).sorted { categoryMap[$0]! < categoryMap[$1]! }, id: \.self) { category in
                        Text(category)
                    }
                }
                                
                HStack(spacing: 12) {
                    Text("\(difficulties[Int(sliderValue)])")
                        .frame(width: 102, alignment: .leading)
                    
                    Slider(value: $sliderValue,
                           in: 0...3,
                           step: 1)
                    .tint(Constants.accentColor)
                }
                                
                Picker("Type", selection: $selectedType) {
                    // Keeps types in the same order; needed since dicts are unordered
                    ForEach(Array(typeMap.keys).sorted { typeMap[$0]! < typeMap[$1]! }, id: \.self) { type in
                        Text(type)
                    }
                }
                
                Picker("Timer Duration", selection: $selectedDuration) {
                    ForEach(durations, id: \ .self) { duration in
                        Text(duration)
                    }
                }
            }
            .foregroundColor(Constants.foregroundColor)
            .listRowBackground(Constants.settingsColor)
        }
        .foregroundColor(Constants.foregroundColor)
        .background(.clear)
        .scrollContentBackground(.hidden)
        .tint(Constants.foregroundColor)
    }
    
    private func convertDuration(_ duration: String) -> Int {
        switch duration {
            case "30 seconds": return 30
            case "60 seconds": return 60
            case "120 seconds": return 120
            case "300 seconds": return 300
            case "1 hour": return 3600
            default: return 30
        }
    }
        
    private func typeURL() -> String {
        if selectedType == "Any Type" { return "" }
        return "&type=\(typeMap[selectedType]!)"
    }
    
    private func difficultyURL() -> String {
        if selectedDifficulty == "Any Difficulty" { return "" }
        return "&difficulty=\(selectedDifficulty.lowercased())"
    }
    
    private func categoryURL() -> String {
        let categoryID = categoryMap[selectedCategory]
        if categoryID == -1 { return "" }
        return "&category=\(categoryID!)"
    }
}

#Preview {
    ContentView()
}
