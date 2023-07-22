//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 11.06.2023.
//

import UIKit

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

//MARK: - Question logic

class QuestionFactory: QuestionFactoryProtocol {
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    func requestNextQuestion() {
        //TODO: move to parameter
        let index = (0..<self.movies.count).randomElement() ?? 0
        guard let movie = self.movies[safe: index] else {
            let error = CustomError.emptyItems(errorMessage: "Problems on server")
            self.delegate?.didFailToLoadData(with: error)
            return
        }
        
        loadImageData(from: movie.resizedImageURL) { image in
            if let image = image {
                //TODO: Move to QuizQuestion
                let rating = Float(movie.rating) ?? 0
                let lessThanRaring = (5...7).randomElement() ?? 0
                let question = QuizQuestion(
                    //TODO: UIImage
                    image: image,
                    text: "Рейтинг этого фильма больше чем \(lessThanRaring)?",
                    correctAnswer: rating > Float(lessThanRaring)
                )
                
                self.delegate?.didReceiveNextQuestion(question: question)
            } else {
                print("Failed to load image")
            }
        }
    }
    
    //TODO: move to image manager
    //TODO: (UIImage?, Error?)
    func loadImageData(from url: URL, completion: @escaping (Data?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil)
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
                
                return
            }
            
            //TODO: uncomment
            if let imageData = data {//, let image = UIImage(data: imageData) {
                completion(data)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    //TODO: move to image manager
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
