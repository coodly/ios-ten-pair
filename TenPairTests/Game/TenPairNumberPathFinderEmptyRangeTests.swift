//
//  TenPairNumberPathFinderEmptyRangeTests.swift
//  TenPair
//
//  Created by Jaanus Siim on 12/06/16.
//  Copyright © 2016 Coodly LLC. All rights reserved.
//

import XCTest
@testable import TenPair

class TenPairEmptyRangeTests: XCTestCase {
    func testIndexIsStartOfRange() {
        let testField = [1, 1, 1, 0, 2, 3]
        let expected = 3
        let result = TenPairEmptyLinesSearch.firstZeroRangeIndexStartingWith(3, inField: testField)
        XCTAssertEqual(expected, result)
    }
    
    func testOneZeroBeforeIndex() {
        let testField = [1, 1, 0, 0, 2, 3]
        let expected = 2
        let result = TenPairEmptyLinesSearch.firstZeroRangeIndexStartingWith(3, inField: testField)
        XCTAssertEqual(expected, result)
    }
    
    func testFieldEmptyBeforeIndex() {
        let testField = [0, 0, 0, 0, 2, 3]
        let expected = 0
        let result = TenPairEmptyLinesSearch.firstZeroRangeIndexStartingWith(3, inField: testField)
        XCTAssertEqual(expected, result)
    }
    
    func testPossiblyEmpryWithOnlyZeroAtIndex() {
        let field = [1, 1, 1, 0, 1, 1, 1]
        let result = TenPairEmptyLinesSearch.possibleEmptyRanges(3, inField: field, rangeLength: 3)
        XCTAssertTrue(result.count == 0)
    }

    func testPossiblyEmptyWithNotEnough() {
        let field = [1, 1, 1, 1, 1, 0, 0]
        let result = TenPairEmptyLinesSearch.possibleEmptyRanges(5, inField: field, rangeLength: 3)
        XCTAssertTrue(result.count == 0)
    }

    func testPossiblyEmptyAtEndOfField() {
        let field = [1, 1, 1, 0, 0, 1, 1]
        let result = TenPairEmptyLinesSearch.possibleEmptyRanges(3, inField: field, rangeLength: 3)
        XCTAssertTrue(result.count == 0)
    }

    func testPossiblyEmptyWithExact() {
        let field = [1, 1, 1, 0, 0, 0, 1]
        let result = TenPairEmptyLinesSearch.possibleEmptyRanges(3, inField: field, rangeLength: 3)
        XCTAssertTrue(result.count == 1)
        let range = result.first!
        XCTAssertEqual(3...5, range)
    }

    func testPossiblyEmptyWithABitMore() {
        let field = [1, 1, 1, 0, 0, 0, 0]
        let result = TenPairEmptyLinesSearch.possibleEmptyRanges(3, inField: field, rangeLength: 3)
        XCTAssertTrue(result.count == 1)
        let range = result.first!
        XCTAssertEqual(3...5, range)
    }

    func testPossiblyEmptyWithMultiple() {
        let field = [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1]
        let result = TenPairEmptyLinesSearch.possibleEmptyRanges(3, inField: field, rangeLength: 3)
        XCTAssertTrue(result.count == 2)
        let first = result[0]
        let second = result[1]
        XCTAssertEqual(3...5, first)
        XCTAssertEqual(6...8, second)
    }
}
