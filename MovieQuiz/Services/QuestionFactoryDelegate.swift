//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 13.06.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
