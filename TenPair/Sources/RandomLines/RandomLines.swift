import Config
import Play
import Save

public class RandomLines {
    private let lines: Int
    public init(lines: Int) {
        self.lines = lines
    }
    
    public func generate() -> [Int] {
        let field = PlayField(save: .noSave)
        field.restart(tiles: DefaultStartBoard)
        
        while field.numberOfLines < lines {
            _ = performMatches(field: field, matched: field.numberOfLines)
            field.reload()
        }
        
        matchToCount(field: field)
        
        return field.numbers
    }
    
    private func matchToCount(field: PlayField) {
        while field.numberOfLines > lines {
            let matchesToMake = max(field.numberOfLines - lines, 1)
            if !performMatches(field: field, matched: matchesToMake) {
                break
            }
        }
    }
    
    private func performMatches(field: PlayField, matched: Int) -> Bool {
        var found = false
        for _ in 0..<matched {
            if let match = field.openMatch() {
                let indexes = Set([match.first, match.second])
                _ = field.clear(numbers: indexes)
                let empty = field.emptyLines(with: indexes)
                field.remove(lines: empty)
                found = true
            } else {
                break
            }
        }
        
        return found
    }
}
