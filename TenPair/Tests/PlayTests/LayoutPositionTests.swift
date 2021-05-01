import XCTest
@testable import Play

final class LayoutPositionTests: XCTestCase {
    private lazy var withAds = LayoutPosition(showingAds: true, adAfterLines: 3)
    private lazy var withoutAds = LayoutPosition(showingAds: false, adAfterLines: 3)
    
    func testNumberOfSection() {
        let field = Array(repeating: 1, count: 90) // 10 lines
        
        XCTAssertEqual(1, withoutAds.numberOfSections(with: field))
        XCTAssertEqual(4 + 3, withAds.numberOfSections(with: field))
    }
    
    func testNumberOfRowsInSection() {
        let field = Array(repeating: 2, count: 91) // 11 lines
        
        XCTAssertEqual(91, withoutAds.numberOfRows(in: 0, using: field))
        
        XCTAssertEqual(27, withAds.numberOfRows(in: 0, using: field))
        XCTAssertEqual(1, withAds.numberOfRows(in: 1, using: field))
        XCTAssertEqual(27, withAds.numberOfRows(in: 2, using: field))
        XCTAssertEqual(1, withAds.numberOfRows(in: 3, using: field))
        XCTAssertEqual(27, withAds.numberOfRows(in: 4, using: field))
        XCTAssertEqual(1, withAds.numberOfRows(in: 5, using: field))
        XCTAssertEqual(10, withAds.numberOfRows(in: 6, using: field))
    }
}
