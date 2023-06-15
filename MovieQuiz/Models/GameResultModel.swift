//
//  GameResultModel.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 14.06.2023.
//

import Foundation

struct GameResult {
    let correctAnswers: Int
    let time = Date().dateTimeString
    let questionsTotal: Int
    
    init(_ correctAnswers: Int, _ questionsTotal: Int) {
        self.correctAnswers = correctAnswers
        self.questionsTotal = questionsTotal
    }
}
