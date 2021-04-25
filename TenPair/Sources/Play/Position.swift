import Config
import CoreGraphics

public struct Position {
    private let itemSize: CGSize
    private let adAfterLines: Int
    private let showingAds: Bool
    
    public init(itemSize: CGSize, adAfterLines: Int, showingAds: Bool) {
        self.itemSize = itemSize
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
}
