//
//  Movie.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 16.06.2023.
//

struct Movie: Codable {
    let id: String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: String
    let image: String
    let crew: String
    let imDbRating: Double
    let imDbRatingCount: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rankValue = Int(rank) else {
            throw ParseError.rankFailure
        }
        self.rank = rankValue
        
        self.title = try container.decode(String.self, forKey: .title)
        self.fullTitle = try container.decode(String.self, forKey: .fullTitle)
        self.year = try container.decode(String.self, forKey: .year)
        self.image = try container.decode(String.self, forKey: .image)
        self.crew = try container.decode(String.self, forKey: .crew)
        
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let ratingValue = Double(imDbRating) else {
            throw ParseError.ratingFailure
        }
        self.imDbRating = ratingValue
        
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let ratingCountValue = Int(imDbRatingCount) else {
            throw ParseError.ratingCountFailure
        }
        self.imDbRatingCount = ratingCountValue
    }
}

struct Top: Decodable {
    let items: [Movie]
}

enum ParseError: Error {
    case rankFailure
    case ratingFailure
    case ratingCountFailure
}


