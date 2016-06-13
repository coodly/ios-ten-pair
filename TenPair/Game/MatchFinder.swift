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
    case Up = -9
    case Down = 9
    case Right = 1
    case Left = -1
    
    static func shuffledValues() -> [Look] {
        return [.Up, .Down, .Left, .Right].shuffle()
    }
}

protocol MatchFinder {
    func openMatchIndex(field: [Int]) -> Int?
}

extension MatchFinder {
    func openMatchIndex(field: [Int]) -> Int? {
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
    
    private func randomBool() -> Bool {
        return arc4random() % 2 == 0
    }
}

private class Finder {
    private let field: [Int]
    private let start: Int
    private let modifier: Int
    
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
    
    private func canSeeMatch(checked: Int, inField field: [Int], look: [Look]) -> Bool {
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
    
    private func nextIndexInDirection(checked: Int, field: [Int], direction: Look) -> Int? {
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

private extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

private extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}