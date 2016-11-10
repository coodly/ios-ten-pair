//
//  MatchFinderTests.swift
//  TenPair
//
//  Created by Jaanus Siim on 13/06/16.
//  Copyright © 2016 Coodly LLC. All rights reserved.
//

import XCTest
@testable import TenPair

class MatchFinderTests: XCTestCase, MatchFinder {
    fileprivate lazy var playField: [Int] = {
        let filePath = Bundle(for: MatchFinderTests.self).path(forResource: "SavedGame", ofType: "plist")!
        let data = NSDictionary(contentsOfFile: filePath)!
        return data[TenPairSaveDataKey] as! [Int]
    }()

    func testEmptyField() {
        let field = [
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0
        ]
        
        XCTAssertNil(openMatchIndex(field))
    }
    
    func testSameMatchFound() {
        let field = [
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 3, 4, 5, 6, 7, 8, 9, 2,
            3, 4, 5, 6, 7, 8, 9, 2, 3,
            4, 5, 6, 7, 8, 9, 2, 3, 4
        ]
        
        let result = openMatchIndex(field)
        XCTAssertNotNil(result)
        guard let check = result else {
            return
        }
        XCTAssertTrue(check == 0 || check == 9)
    }

    func testAddMatchFound() {
        let field = [
            1, 2, 3, 4, 5, 6, 7, 8, 9,
            2, 3, 4, 5, 6, 7, 8, 9, 2,
            3, 4, 5, 6, 7, 3, 9, 2, 3,
            4, 5, 6, 7, 8, 9, 2, 3, 4
        ]
        
        let result = openMatchIndex(field)
        XCTAssertNotNil(result)
        guard let check = result else {
            return
        }
        XCTAssertTrue(check == 14 || check == 22 || check == 23)
    }

    func testBigField() {
        self.measureBlock {
            self.openMatchIndex(self.playField)
        }
    }
}
