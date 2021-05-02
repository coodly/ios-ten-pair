import XCTest
@testable import Play

final class LayoutPositionTests: XCTestCase {
    private lazy var withAds = LayoutPosition(showingAds: true, adAfterLines: 3, itemSize: CGSize(width: 10, height: 10), adSize: CGSize(width: 90, height: 30))
    private lazy var withoutAds = LayoutPosition(showingAds: false, adAfterLines: 3, itemSize: CGSize(width: 10, height: 10), adSize: CGSize(width: 90, height: 30))
    
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
    
    func testContentHeight() {
        let oneAndHalfLines = Array(repeating: 1, count: 12)
        let twoAndHalfLines = Array(repeating: 1, count: 2 * 9 + 3)
        let tenLines = Array(repeating: 3, count: 90)
        let twentyLines = Array(repeating: 3, count: 180)
        
        XCTAssertEqual(20, withoutAds.contentHeight(using: oneAndHalfLines))
        XCTAssertEqual(30, withoutAds.contentHeight(using: twoAndHalfLines))
        XCTAssertEqual(10 * 10, withoutAds.contentHeight(using: tenLines))
        XCTAssertEqual(10 * 20, withoutAds.contentHeight(using: twentyLines))

        XCTAssertEqual(20, withAds.contentHeight(using: oneAndHalfLines))
        XCTAssertEqual(30, withAds.contentHeight(using: twoAndHalfLines))
        XCTAssertEqual(10 * 10 + 30 * 3, withAds.contentHeight(using: tenLines))
        XCTAssertEqual(10 * 20 + 30 * 6, withAds.contentHeight(using: twentyLines))
    }
    
    func testPositionOfCell() {
        XCTAssertEqual(CGPoint.zero, withoutAds.position(of: 0, in: 0))
        XCTAssertEqual(CGPoint(x: 80, y: 0), withoutAds.position(of: 8, in: 0))
        XCTAssertEqual(CGPoint(x: 80, y: 10), withoutAds.position(of: 17, in: 0))
        XCTAssertEqual(CGPoint(x: 80, y: 20), withoutAds.position(of: 26, in: 0))
        XCTAssertEqual(CGPoint(x: 10, y: 30), withoutAds.position(of: 28, in: 0))
        
        XCTAssertEqual(CGPoint.zero, withAds.position(of: 0, in: 0))
        XCTAssertEqual(CGPoint(x: 0, y: 30), withAds.position(of: 0, in: 1))
        XCTAssertEqual(CGPoint(x: 0, y: 60), withAds.position(of: 0, in: 2))
        XCTAssertEqual(CGPoint(x: 0, y: 90), withAds.position(of: 0, in: 3))
        XCTAssertEqual(CGPoint(x: 40, y: 120), withAds.position(of: 4, in: 4))
    }
    
    func testContentHeightWithSections() {
        XCTAssertEqual(20, withoutAds.contentHeight(with: 1, itemsInLast: 12))
        XCTAssertEqual(30, withoutAds.contentHeight(with: 1, itemsInLast: 21))
        XCTAssertEqual(10 * 10, withoutAds.contentHeight(with: 1, itemsInLast: 90))
        XCTAssertEqual(20 * 10, withoutAds.contentHeight(with: 1, itemsInLast: 180))

        XCTAssertEqual(20, withAds.contentHeight(with: 1, itemsInLast: 12))
        XCTAssertEqual(30, withAds.contentHeight(with: 1, itemsInLast: 21))
        
        // one tile after first ad
        XCTAssertEqual(10 * 3 + 30 + 10, withAds.contentHeight(with: 3, itemsInLast: 1))

        // two rows after second ad
        XCTAssertEqual(10 * (3 + 3 + 2) + 30 * 2, withAds.contentHeight(with: 5, itemsInLast: 12))
    }
}
