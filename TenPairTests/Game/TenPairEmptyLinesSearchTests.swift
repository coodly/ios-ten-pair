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

class TenPairEmptyLinesSearchTests: XCTestCase {
    func testNoEmptyLines() {
        let testField = [
            0, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 0, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 0
        ]
        
        emptyLinesCheck([0, 13], field: testField, expected: [], tag: "11")
        emptyLinesCheck([13, 0], field: testField, expected: [], tag: "12")

        emptyLinesCheck([26, 13], field: testField, expected: [], tag: "13")
        emptyLinesCheck([13, 26], field: testField, expected: [], tag: "14")

        emptyLinesCheck([26, 0], field: testField, expected: [], tag: "15")
        emptyLinesCheck([0, 26], field: testField, expected: [], tag: "16")
    }
    
    func testHasEmptyLines() {
        let testField = [
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0
        ]
        
        emptyLinesCheck([0, 8], field: testField, expected: [0], tag: "21")
        emptyLinesCheck([8, 0], field: testField, expected: [0], tag: "22")

        emptyLinesCheck([0, 9], field: testField, expected: [0, 1], tag: "23")
        emptyLinesCheck([9, 0], field: testField, expected: [0, 1], tag: "24")

        emptyLinesCheck([0, 79], field: testField, expected: [0, 8], tag: "25")
        emptyLinesCheck([79, 0], field: testField, expected: [0, 8], tag: "26")

        emptyLinesCheck([72, 80], field: testField, expected: [8], tag: "27")
        emptyLinesCheck([80, 72], field: testField, expected: [8], tag: "28")
    }
    
    func testPartialRow() {
        let testField = [
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0
        ]

        emptyLinesCheck([0, 20], field: testField, expected: [0], tag: "31")
        emptyLinesCheck([20, 0], field: testField, expected: [0], tag: "32")
    }
    
    func emptyLinesCheck(probes: [Int], field: [Int], expected: [Int], tag: String) {
        var result = TenPairEmptyLinesSearch.emptyLinesWithCheckPoints(probes, field: field)
        result.sortInPlace()
        var sortedExpected = expected
        sortedExpected.sortInPlace()
        
        XCTAssert(result.count == expected.count, "\(tag) - not same length. Expected \(expected), got \(result)")
        
        for var index = 0; index < expected.count && index < result.count; index++ {
            let one = result[index]
            let two = expected[index]
            XCTAssert(one == two, "\(tag) - \(index) not equal")
        }
    }
}