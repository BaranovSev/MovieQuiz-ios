//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Stepan Baranov on 16.06.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int) 
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get {
            return 0.0
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                let record = 0
                userDefaults.set(record, forKey: Keys.gamesCount.rawValue)
                return record
            }
            
            return record
        }

        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newResult = GameRecord(correct: count, total: amount, date: Date())
        if  bestGame < newResult  {
            bestGame = newResult
        }
        gamesCount = gamesCount + 1
        userDefaults.set(gamesCount, forKey: Keys.gamesCount.rawValue)
        
    }
    
    
    
}
