import Config
import CoreGraphics

public struct Position {
    private let itemSize: CGSize
    private let adSize: CGSize
    private let adAfterLines: Int
    private let showingAds: Bool
    
    public init(itemSize: CGSize, adSize: CGSize, adAfterLines: Int, showingAds: Bool) {
        self.itemSize = itemSize
        self.adSize = adSize
        self.adAfterLines = adAfterLines
        self.showingAds = showingAds
    }
    
    public func hasAd(on tile: Tile) -> Bool {
        guard showingAds else {
            return false
        }
        
        let pageLines = adAfterLines + 1
        let mod = tile.line % pageLines
        return mod == pageLines - 1
    }
    
    public func frame(for tile: Tile) -> CGRect {
        let pageLines = adAfterLines + 1
        let onPage = tile.line / pageLines
        let pageHeight = CGFloat(adAfterLines) * itemSize.height + adSize.height
        let lineOnPage = tile.line % pageLines
        let positionX = CGFloat(tile.column) * itemSize.width
        let positionY = CGFloat(onPage) * pageHeight + CGFloat(lineOnPage) * itemSize.height
        let itemSize = hasAd(on: tile) ? adSize : itemSize
        return CGRect(origin: CGPoint(x: positionX, y: positionY), size: itemSize)
    }
}
