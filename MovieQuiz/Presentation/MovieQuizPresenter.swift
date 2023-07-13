//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 13.07.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let currentQuestionAnswer = currentQuestion.correctAnswer
        let userAnswer = true
        
        viewController?.showAnswerResult(isCorrect: currentQuestionAnswer == userAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let currentQuestionAnswer = currentQuestion.correctAnswer
        let userAnswer = false
        viewController?.showAnswerResult(isCorrect: currentQuestionAnswer == userAnswer)
    }
}
