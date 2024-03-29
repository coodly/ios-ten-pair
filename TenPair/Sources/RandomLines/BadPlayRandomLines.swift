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

import Config
import GameKit
import Play
import Save

extension RandomLines {
    internal static let badPlay: RandomLines = {
        return RandomLines(
            generate: {
                lines in
                
                BadPlayRandomLines(lines: lines, random: GKMersenneTwisterRandomSource()).generate()
            }
        )
    }()
}

private class BadPlayRandomLines {
    private let lines: Int
    private let random: GKMersenneTwisterRandomSource
    fileprivate init(lines: Int, random: GKMersenneTwisterRandomSource) {
        self.lines = lines
        self.random = random
    }
    
    fileprivate func generate() -> [Int] {
        let field = PlayField(save: .noSave, random: random)
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
