/*
* Copyright 2015 Coodly LLC
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import XCTest

class TenPairNumberPathFinderTests: XCTestCase {
    func testSideBySide() {
        let testField = [
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9
        ]
        
        performChecWithField(testField, testIndexes: [0, 1], expectedResult: true, tag: "11")

        performChecWithField(testField, testIndexes: [4, 13], expectedResult: true, tag: "12")

        performChecWithField(testField, testIndexes: [0, 18], expectedResult: false, tag: "13")

        performChecWithField(testField, testIndexes: [0, 26], expectedResult: false, tag: "14")
    }
    
    func testSameHorizontalRow() {
        let testField = [5, 5, 0, 5, 0, 0, 0, 0, 5]
        
        performChecWithField(testField, testIndexes: [1, 3], expectedResult: true, tag: "21")

        performChecWithField(testField, testIndexes: [3, 8], expectedResult: true, tag: "22")

        performChecWithField(testField, testIndexes: [1, 8], expectedResult: false, tag: "23")
    }
    
    func testOnSameVerticalRow() {
        let testField = [
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 0, 5, 6, 7, 8, 9,
            1, 2, 3, 0, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 0, 5, 6, 7, 8, 9,
            1, 2, 3, 0, 5, 6, 7, 8, 9,
            1, 2, 3, 0, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9
        ]

        performChecWithField(testField, testIndexes: [12, 39], expectedResult: true, tag: "31")

        performChecWithField(testField, testIndexes: [75, 39], expectedResult: true, tag: "32")
    
        performChecWithField(testField, testIndexes: [75, 12], expectedResult: false, tag: "33")
    }
    
    func testOnSamePath() {
        let testField = [
            1, 2, 0, 0, 0, 0, 0, 0, 0,
            1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9
        ]
        
        performChecWithField(testField, testIndexes: [1, 9], expectedResult: true, tag: "41")

        performChecWithField(testField, testIndexes: [23, 9], expectedResult: true, tag: "41")

        performChecWithField(testField, testIndexes: [23, 1], expectedResult: false, tag: "41")
    }
    

    func testOnSameHorisontalLine() {
        XCTAssert(TenPairNumberPathFinder.onSameHorisontalLine(0, secondIndex: 8), "Failed")

        XCTAssert(TenPairNumberPathFinder.onSameHorisontalLine(3, secondIndex: 7), "Failed")

        XCTAssert(TenPairNumberPathFinder.onSameHorisontalLine(6, secondIndex: 8), "Failed")

        XCTAssert(!TenPairNumberPathFinder.onSameHorisontalLine(0, secondIndex: 9), "Failed")

        XCTAssert(!TenPairNumberPathFinder.onSameHorisontalLine(0, secondIndex: 27), "Failed")
    }
    
    func testOnSameVerticalLine() {
        XCTAssert(TenPairNumberPathFinder.onSameVerticalLine(0, secondIndex: 9), "Failed")

        XCTAssert(TenPairNumberPathFinder.onSameVerticalLine(0, secondIndex: 18), "Failed")

        XCTAssert(!TenPairNumberPathFinder.onSameVerticalLine(0, secondIndex: 7), "Failed")

        XCTAssert(!TenPairNumberPathFinder.onSameVerticalLine(0, secondIndex: 12), "Failed")
        
        XCTAssert(!TenPairNumberPathFinder.onSameVerticalLine(0, secondIndex: 13), "Failed")
    }
    
    func performChecWithField(field: [Int], testIndexes: [Int], expectedResult: Bool, tag: String) {
        let resultOne = TenPairNumberPathFinder.hasClearPath(testIndexes, inField: field)
        let resultTwo = TenPairNumberPathFinder.hasClearPath(Array(testIndexes.reverse()), inField: field)
        XCTAssert(resultOne == expectedResult, "One way. Got wrong result - \(tag) - \(resultOne) - \(expectedResult)")
        XCTAssert(resultTwo == expectedResult, "Other way. Got wrong result - \(tag) - \(resultTwo) - \(expectedResult)")
    }
}
