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
}
