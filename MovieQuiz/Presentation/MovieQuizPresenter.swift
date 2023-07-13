//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 13.07.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var currentQuestionIndex = 0
    private let statisticService: StatisticService = StatisticServiceImplementation()
    private var questionFactory: QuestionFactoryProtocol?
    var correctAnswers = 0
    
    init(viewController:MovieQuizViewController){
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Functions
    func loadDataAfterError() {
        questionFactory?.loadData()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(NSString(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let alertModel = AlertModel(
                title: "Раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз"
            ) { [weak self] in
                guard let self = self else { return }
                
                self.restartGame()
            }
            
            guard let viewController = self.viewController else {
                return
            }
            
            AlertPresenter(onViewController: viewController).showAlert(alert: alertModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let currentQuestionAnswer = currentQuestion.correctAnswer
        let userAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: currentQuestionAnswer == userAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let currentQuestionAnswer = currentQuestion.correctAnswer
        let userAnswer = isCorrectAnswer
        if currentQuestionAnswer == userAnswer {
            correctAnswers += 1
        }
    }
}
