//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 11.06.2023.
//

import Foundation

public enum CustomError: Error {
    case emptyItems(errorMessage: String)
    case imageLoaderError
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyItems(let errorMessage):
            return NSLocalizedString(errorMessage, comment: "Client error")
        case .imageLoaderError:
            return NSLocalizedString("Image load error", comment: "Image load error")
        }
    }
}

class QuestionFactory: QuestionFactoryProtocol {
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else {
                DispatchQueue.main.async {
                    let error = CustomError.emptyItems(errorMessage: "Problems on server")
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async {
                    let error = CustomError.imageLoaderError
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let lessThanRaring = (5...7).randomElement() ?? 0
            let text = "Рейтинг этого фильма больше чем \(lessThanRaring)?"
            let correctAnswer = rating > Float(lessThanRaring)
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
}
