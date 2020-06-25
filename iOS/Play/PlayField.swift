/*
* Copyright 2020 Coodly LLC
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
import UIKit

internal enum MatchAction: String {
    case match
    case failure
}

internal protocol PlayFieldStatusDelegate: class {
    func statusUpdate(lines: Int, tiles: Int)
}

internal class PlayField: MatchFinder {
    private var numbers = [Int]()
    private var clearedCount = 0
    private var numberOfLines = 0 {
        didSet {
            forwardStatus()
        }
    }
    private var numberOfTiles = 0 {
        didSet {
            forwardStatus()
        }
    }
    
    internal weak var statusDelegate: PlayFieldStatusDelegate? {
        didSet {
            forwardStatus()
        }
    }
    
    private func forwardStatus() {
        DispatchQueue.main.async {
            self.statusDelegate?.statusUpdate(lines: self.numberOfLines, tiles: self.numberOfTiles)
        }
    }
    
    internal func load() {
        numbers = FieldSave.load()
        updateStatus()
    }
    
    internal func save() {
        FieldSave.save(numbers)
    }
    
    internal var count: Int {
        numbers.count
    }
    
    internal func number(at index: Int) -> Int {
        numbers[index]
    }
    
    internal func reload() {
        let added = numbers.filter({ $0 != 0 })
        numbers.append(contentsOf: added)
        
        save()
        
        updateStatus()
    }
    
    internal func match(first: Int, second: Int) -> MatchAction {
        guard NumbersPathFinder.hasClearPath([first, second], inField: numbers) else {
            return .failure
        }
        
        let valueOne = numbers[first]
        let valueTwo = numbers[second]
        
        guard valueOne == valueTwo || valueOne + valueTwo == 10 else {
            return .failure
        }

        return .match
    }
    
    internal func clear(numbers: Set<Int>) {
        numbers.forEach({ self.numbers[$0] = 0 })
        numberOfTiles -= numbers.count
        
        clearedCount += 1
        guard clearedCount.isMultiple(of: 100) else {
            return
        }
        
        clearedCount = 0
        save()
    }
    
    internal func hasValue(at index: Int) -> Bool {
        numbers[index] != 0
    }
    
    internal func openMatch() -> Int? {
        openMatchIndex(numbers)
    }
    
    internal func emptyLines(with pointers: Set<Int>) -> [CountableRange<Int>] {
        let points = Array(pointers.sorted().reversed())
        return EmptyLinesSearch.emptyRangesWithCheckPoints(points, field: numbers)
    }
    
    internal func remove(lines removed: [CountableRange<Int>]) {
        let lines = removed.sorted(by: { $0.lowerBound > $1.lowerBound })
        for removed in lines {
            numbers.removeSubrange(removed)
        }
        updateLines()
    }
    
    private func updateStatus() {
        updateLines()
        countTiles()
    }
    
    private func updateLines() {
        numberOfLines = Int((CGFloat(numbers.count) / ColumnsF).rounded(.up))
    }
    
    private func countTiles() {
        numberOfTiles = numbers.filter({ $0 != 0 }).count
    }
    
    internal func restart(with lines: Int) {
        if lines == 0 {
            numbers = DefaultStartBoard
        } else {
            let tileNumbers = 0..<10
            let tiles = lines * NumberOfColumns
            numbers =  (0..<tiles).compactMap({ _ in tileNumbers.randomElement() })
        }
        
        save()
        updateStatus()
    }
}
