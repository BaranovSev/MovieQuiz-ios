//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Stepan Baranov on 06.07.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        //Given
        let array = [55, 1, 2, 3, 5]
        
        //When
        let value = array[safe: 2]
        let value2 = array[safe: 0]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        XCTAssertEqual(value2, 55)
    }

    func testGetValueOutOfRange() throws {
        //Given
        let array = [55, 1, 2, 3, 5]

        //When
        let value = array[safe: 20]

        //Then
        XCTAssertNil(value)
    }
}
