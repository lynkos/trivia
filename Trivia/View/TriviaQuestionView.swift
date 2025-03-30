//
//  TriviaQuestionView.swift
//  Trivia
//
//  Created by Kiran Brahmatewari on 3/28/25.

import SwiftUI

struct TriviaQuestionView: View {
    let triviaQuestion: TriviaQuestion
    @Binding var selectedAnswer: String?

    var body: some View {
        ZStack {
            overlayView
        }
        .background(Constants.buttonColor)
        .cornerRadius(20)
        .padding(5)
    }
        
    @ViewBuilder
    private var overlayView: some View {
        VStack {
            Text(triviaQuestion.question)
                .padding(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(triviaQuestion.answers, id: \.self) { answer in
                TriviaAnswerView(title: answer, selectedAnswer: $selectedAnswer)
                    .padding(4) // default: 16
                    .font(.system(size: 20))
                    .onTapGesture {
                        selectedAnswer = answer
                    }
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(.white)
        .padding()
    }
}
