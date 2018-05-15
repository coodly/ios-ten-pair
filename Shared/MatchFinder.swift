/*
 * Copyright 2015 Coodly LLC
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

private enum Look: Int {
    case up = -9
    case down = 9
    case right = 1
    case left = -1
    
    static func shuffledValues() -> [Look] {
        return [.up, .down, .left, .right].shuffled()
    }
}

protocol MatchFinder {
    func openMatchIndex(_ field: [Int]) -> Int?
}

extension MatchFinder {
    func openMatchIndex(_ field: [Int]) -> Int? {
        let randomIndex = Int(arc4random_uniform(UInt32(field.count)))
        let searchBackwards = randomBool()
        let search = Finder(field: field, startIndex: randomIndex, searchBackwards: searchBackwards)
        if let found = search.find() {
            return found
        }
        
        let searchTwo = Finder(field: field, startIndex: randomIndex, searchBackwards: !searchBackwards)
        if let found = searchTwo.find() {
            return found
        }
        
        return nil
    }
    
    fileprivate func randomBool() -> Bool {
        return arc4random() % 2 == 0
    }
}

private class Finder {
    fileprivate let field: [Int]
    fileprivate let start: Int
    fileprivate let modifier: Int
    
    init(field: [Int], startIndex: Int, searchBackwards: Bool) {
        self.field = field
        self.start = startIndex
        modifier = searchBackwards ? -1 : 1
    }
    
    func find() -> Int? {
        var checked = start
        
        let looking = Look.shuffledValues()
        
        repeat {
            let value = field[checked]
            if value != 0 && canSeeMatch(checked, inField: field, look: looking) {
                return checked
            }
            
            checked += modifier
        } while checked >= 0 && checked < field.count
        
        return nil
    }
    
    fileprivate func canSeeMatch(_ checked: Int, inField field: [Int], look: [Look]) -> Bool {
        let indexValue = field[checked]
        for looking in look {
            guard let checkAgainst = nextIndexInDirection(checked, field: field, direction: looking) else {
                continue
            }
            
            let otherValue = field[checkAgainst]
            
            if indexValue == otherValue || indexValue + otherValue == 10 {
                return true
            }
        }
        
        return false
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

//http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift/24029847#24029847
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
