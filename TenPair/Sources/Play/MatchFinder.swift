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

import Foundation
import GameKit

private enum Look: Int, CaseIterable {
    case up = -9
    case down = 9
    case right = 1
    case left = -1
}

public struct Match {
    public let first: Int
    public let second: Int
}

public class MatchFinder {
    public static func openMatch(in field: [Int], random: GKRandomSource) -> Match? {
        let randomIndex = random.nextInt(upperBound: field.count)
        let searchBackwards = random.nextBool()
        let search = Finder(field: field, startIndex: randomIndex, searchBackwards: searchBackwards, random: random)
        if let found = search.find() {
            return found
        }
        
        let searchTwo = Finder(field: field, startIndex: randomIndex, searchBackwards: !searchBackwards, random: random)
        if let found = searchTwo.find() {
            return found
        }
        
        return nil
    }
}

private class Finder {
    fileprivate let field: [Int]
    fileprivate let start: Int
    fileprivate let modifier: Int
    private let random: GKRandomSource
    
    init(field: [Int], startIndex: Int, searchBackwards: Bool, random: GKRandomSource) {
        self.field = field
        self.start = startIndex
        modifier = searchBackwards ? -1 : 1
        self.random = random
    }
    
    fileprivate func find() -> Match? {
        var checked = start
        
        let looking: [Look] = random.arrayByShufflingObjects(in: Look.allCases) as! [Look]
        
        repeat {
            let value = field[checked]
            if value != 0, let matched = canSeeMatch(checked, inField: field, look: looking) {
                return Match(first: checked, second: matched)
            }
            
            checked += modifier
        } while checked >= 0 && checked < field.count
        
        return nil
    }
    
    fileprivate func canSeeMatch(_ checked: Int, inField field: [Int], look: [Look]) -> Int? {
        let indexValue = field[checked]
        for looking in look {
            guard let checkAgainst = nextIndexInDirection(checked, field: field, direction: looking) else {
                continue
            }
            
            let otherValue = field[checkAgainst]
            
            if indexValue == otherValue || indexValue + otherValue == 10 {
                return checkAgainst
            }
        }
        
        return nil
    }
    
    fileprivate func nextIndexInDirection(_ checked: Int, field: [Int], direction: Look) -> Int? {
        var otherIndex = checked
        while true {
            otherIndex += direction.rawValue
            
            guard otherIndex >= 0 && otherIndex < field.count else {
                break
            }
            
            if field[otherIndex] != 0 {
                return otherIndex
            }
        }
        return nil
    }
}
