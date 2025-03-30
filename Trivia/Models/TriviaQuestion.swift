//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Kiran Brahmatewari on 3/28/25.

import Foundation

struct TriviaQuestion: Codable, Identifiable {
    var id: String { UUID().uuidString }
    let question: String
    var answers: [String]
    let correct_answer: String
}
