/*
* Copyright 2021 Coodly LLC
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

import XCTest
@testable import Play

final class PositionWithAdsTests: XCTestCase {
    private let position = Position(itemSize: CGSize(width: 10, height: 10), adSize: CGSize(width: 90, height: 30), adAfterLines: 3, showingAds: true)

    // 0 |> 0, 1, 2, 3, 4, 5, 6, 7, 8
    // 1 |> 9, ...
    // 2 |> 18, ...
    // 3 |> 27 - ad
    // 4 |> 28, 29, 30, 31, 32, 33, 34, 35, 36,
    // 5 |> 37, 38, 39, 40, 41, 42, 43, 44, 45,
    // 6 |> 46, ...
    // 7 |> 55 - ad

    func testFirstAdPosition() {
        XCTAssertFalse(position.hasAd(on: Tile(line: 2, column: 8)))
        XCTAssertTrue(position.hasAd(on: Tile(line: 3, column: 0)))
        XCTAssertFalse(position.hasAd(on: Tile(line: 4, column: 0)))
    }
    
    func testSecondAdPosition() {
        XCTAssertFalse(position.hasAd(on: Tile(line: 6, column: 8)))
        XCTAssertTrue(position.hasAd(on: Tile(line: 7, column: 0)))
        XCTAssertFalse(position.hasAd(on: Tile(line: 8, column: 0)))
    }
    
    func testFranes() {
        XCTAssertEqual(CGRect(origin: .zero, size: CGSize(width: 10, height: 10)), position.frame(for: Tile(line: 0, column: 0)))
        XCTAssertEqual(CGRect(x: 10, y: 20, width: 10, height: 10), position.frame(for: Tile(line: 2, column: 1)))
        
        //after first ad
        XCTAssertEqual(CGRect(x: 20, y: 60, width: 10, height: 10), position.frame(for: Tile(line: 4, column: 2)))

        //after second ad
        XCTAssertEqual(CGRect(x: 30, y: 120, width: 10, height: 10), position.frame(for: Tile(line: 8, column: 3)))
    }
    
    func testFrameOfFirstAd() {
        XCTAssertEqual(CGRect(x: 0, y: 30, width: 90, height: 30), position.frame(for: Tile(line: 3, column: 0)))
    }

    func testFrameOfSecondAd() {
        XCTAssertEqual(CGRect(x: 0, y: 90, width: 90, height: 30), position.frame(for: Tile(line: 7, column: 0)))
    }
    
    func testNumberOfAds() {
        XCTAssertEqual(0, position.numberOfAds(with: 18))
        XCTAssertEqual(1, position.numberOfAds(with: 27))
        XCTAssertEqual(1, position.numberOfAds(with: 28))
        XCTAssertEqual(2, position.numberOfAds(with: 64))
    }
    
    func testTileFromIndex() {
        XCTAssertEqual(Tile(line: 0, column: 0), position.tile(from: 0))
        XCTAssertEqual(Tile(line: 2, column: 0), position.tile(from: 18))
        XCTAssertEqual(Tile(line: 2, column: 1), position.tile(from: 19))
        
        XCTAssertEqual(Tile(line: 3, column: 0), position.tile(from: 27)) // first ad
        
        XCTAssertEqual(Tile(line: 4, column: 0), position.tile(from: 28))
        XCTAssertEqual(Tile(line: 6, column: 8), position.tile(from: 54))
        
        XCTAssertEqual(Tile(line: 7, column: 0), position.tile(from: 55)) // second ad
        
        XCTAssertEqual(Tile(line: 8, column: 0), position.tile(from: 56))
    }
    
    func testIndexWithoutAds() {
        XCTAssertEqual(0, position.indexWithoutAd(from: 0))
        XCTAssertEqual(26, position.indexWithoutAd(from: 26))
        
        XCTAssertEqual(27, position.indexWithoutAd(from: 28))
        
        XCTAssertEqual(53, position.indexWithoutAd(from: 54))
        
        XCTAssertEqual(54, position.indexWithoutAd(from: 56))
    }
}
