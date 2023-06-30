//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 14.06.2023.
//

import UIKit

class AlertPresenter {
    weak var onViewController: MovieQuizViewController?
    
    func showAlert(alert result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(action)
        onViewController?.present(alert, animated: true, completion: nil)
    }
    
    init(onViewController: MovieQuizViewController) {
        self.onViewController = onViewController
    }
}
