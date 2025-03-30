//
//  GameView.swift
//  Trivia
//
//  Created by Kiran Brahmatewari on 3/28/25.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedAnswers: [String?]

    @State private var trivias: [Trivia] = []
    @State private var triviaQuestions: [TriviaQuestion] = []
    @State private var isLoading: Bool = false
    @State private var score = 0
    @State private var showAlert = false
    @State private var timeRemaining: Int  = 30
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // API Values
    let numberOfQuestions: Int
    let category: String
    let difficulty: String
    let type: String
    let duration: Int
    
    private var API_URL: String {
        "https://opentdb.com/api.php?amount=\(numberOfQuestions)\(category)\(difficulty)\(type)"
    }
    
    init(numberOfQuestions: Int, category: String, difficulty: String, type: String, duration: Int) {
        self.numberOfQuestions = numberOfQuestions
        self.category = category
        self.difficulty = difficulty
        self.type = type
        self.duration = duration
        
        _timeRemaining = State(initialValue: duration)
        _selectedAnswers = State(initialValue: Array(repeating: nil, count: numberOfQuestions))
    }
    
    private func fetchQuestions() async {
        self.isLoading = true
        
        guard let url = URL(string: API_URL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            do {
                let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let triviaResults = triviaResponse.results
                self.trivias = triviaResults
                
                DispatchQueue.main.async {
                    for trivia in triviaResults {
                        var duplicateAnswers = trivia.incorrect_answers.map { $0.htmlDecoded }
                        duplicateAnswers.append(trivia.correct_answer.htmlDecoded)
                        duplicateAnswers.shuffle()
                        
                        self.triviaQuestions.append(TriviaQuestion(
                            question: trivia.question.htmlDecoded,
                            answers: duplicateAnswers,
                            correct_answer: trivia.correct_answer.htmlDecoded
                        ))
                    }

                    self.isLoading = false
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    var body: some View {
        VStack {
            if self.isLoading {
                ProgressView("Loading Trivia...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .font(.title2)
                    .padding()
            } else {
                if self.triviaQuestions.isEmpty {
                    Text("Questions still loading or unavailable.\nPlease wait or try again.")
                        .foregroundColor(Constants.foregroundColor)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    showTimer
                    
                    ScrollView {
                        LazyVStack { // VStack
                            questions
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        } else {
                            timer.upstream.connect().cancel()
                            calculateScore()
                            showAlert = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Score"),
                            message: Text("You scored \(score) out of \(numberOfQuestions)"),
                            dismissButton: .default(Text("OK"), action: {
                                dismiss()
                            })
                        )
                    }
                    
                    submitButton
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.backgroundColor)
        .onAppear {
            Task {
                self.isLoading = true
                await fetchQuestions()
                self.isLoading = false
            }
        }
    }
        
    private func calculateScore() {
        for (index, question) in self.triviaQuestions.enumerated() {
            // Ensure selected answer exists and is correct
            if selectedAnswers.indices.contains(index), let selectedAnswer = selectedAnswers[index], selectedAnswer == question.correct_answer {
                score += 1
            }
        }
    }
    
    @ViewBuilder
    private var questions: some View {
        ForEach(self.triviaQuestions.indices, id: \.self) { index in
            TriviaQuestionView(
                triviaQuestion: self.triviaQuestions[index],
                selectedAnswer: $selectedAnswers[index]
            )
        }
        .font(.title)
    }
    
    @ViewBuilder
    private var showTimer: some View {
        Text("Time Remaining: \(timeRemaining)s")
            .font(.system(size: 20, weight: .semibold))
            .padding(.top)
            .foregroundColor(timeRemaining > 10 ? Constants.foregroundColor : .red) // Red when time is low
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private var submitButton: some View {
        Button(action: {
            calculateScore()
            showAlert = true
        }) {
            Text("Submit")
                .font(.system(size: 22, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Constants.buttonColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(.horizontal)
                .disabled(timeRemaining == 0)
        }
    }
}

extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string
        
        return decoded ?? self
    }
}

#Preview {
    let numberOfQuestions: Int = 5
    let category: String = ""
    let difficulty: String = ""
    let type: String = ""
    let duration: Int = 30

    GameView(
        numberOfQuestions: numberOfQuestions,
        category: category,
        difficulty: difficulty,
        type: type,
        duration: duration
    )
}
