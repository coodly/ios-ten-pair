import XCTest
@testable import Play

final class PositionWithAdsTests: XCTestCase {
    private let position = Position(itemSize: CGSize(width: 10, height: 10), adAfterLines: 3, showingAds: true)

    // 0 |> 0, 1, 2, 3, 4, 5, 6, 7, 8
    // 1 |> 9, ...
    // 2 |> 18, ...
    // 3 |> 27 - ad
    // 4 |> 28, 28, 30, 31, 32, 33, 34, 35, 36,
    // 5 |> 37, ...
    // 6 |> 46, ...
    // 7 |> 45 - ad

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
}
