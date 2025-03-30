//
//  TriviaAnswerView.swift
//  Trivia
//
//  Created by Kiran Brahmatewari on 3/28/25.

import SwiftUI

struct TriviaAnswerView: View {
    @State var title: String
    @Binding var selectedAnswer: String?
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: title == selectedAnswer ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(title == selectedAnswer ? Constants.accentColor : .white)
                    .onTapGesture {
                        self.selectedAnswer = self.title
                    }
                Text(title)
                Spacer()
            }
        }
    }
}
