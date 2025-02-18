//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 14.06.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
