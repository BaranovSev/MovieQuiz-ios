//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Stepan Baranov on 07.07.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() throws {
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() throws {
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameAlert() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Раунд окончен!"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
        
    func testGameAlertButton() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Раунд окончен!"]
        alert.buttons.firstMatch.tap()
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        let randomPoster = app.images["Poster"]
        let question = app.staticTexts["Question"]
        let noButton = app.buttons["No"]
        let yesButton = app.buttons["Yes"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
        XCTAssertTrue(randomPoster.exists)
        XCTAssertTrue(question.exists)
        XCTAssertTrue(noButton.exists)
        XCTAssertTrue(yesButton.exists)
    }
}
