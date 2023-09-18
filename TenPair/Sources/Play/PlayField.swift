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

import Config
import Foundation
import GameKit
import Save
import UIKit

public enum MatchAction: String {
    case match
    case failure
}

public protocol PlayFieldStatusDelegate: AnyObject {
    func statusUpdate(lines: Int, tiles: Int)
}

public struct Position {
    public let index: Int
    public let value: Int
    
    public init(index: Int, value: Int) {
        self.index = index
        self.value = value
    }
}


public class PlayField {
    private(set) public var numbers = [Int]()
    private var clearedCount = 0
    private(set) public var numberOfLines = 0 {
        didSet {
            forwardStatus()
        }
    }
    private(set) public var numberOfTiles = 0 {
        didSet {
            forwardStatus()
        }
    }
    
    public weak var statusDelegate: (any PlayFieldStatusDelegate)? {
        didSet {
            forwardStatus()
        }
    }
    
    private let fieldSave: FieldSave
    private let random: GKRandomSource
    public init(save: FieldSave, random: GKRandomSource) {
        self.fieldSave = save
        self.random = random
    }
    
    private func forwardStatus() {
        DispatchQueue.main.async {
            self.statusDelegate?.statusUpdate(lines: self.numberOfLines, tiles: self.numberOfTiles)
        }
    }
    
    public func load() {
        numbers = fieldSave.load()
        updateStatus()
    }
    
    public func save() {
        fieldSave.save(numbers)
    }
    
    internal var count: Int {
        numbers.count
    }
    
    public func number(at index: Int) -> Int {
        numbers[index]
    }
    
    public func reload() {
        let added = numbers.filter({ $0 != 0 })
        numbers.append(contentsOf: added)
        
        save()
        
        updateStatus()
    }
    
    public func match(first: Int, second: Int) -> MatchAction {
        guard PathFinder.hasClearPath([first, second], inField: numbers) else {
            return .failure
        }
        
        let valueOne = numbers[first]
        let valueTwo = numbers[second]
        
        guard valueOne == valueTwo || valueOne + valueTwo == 10 else {
            return .failure
        }

        return .match
    }
    
    public func clear(numbers: Set<Int>) -> [Position] {
        var positions = [Position]()
        for index in numbers {
            let value = self.numbers[index]
            positions.append(Position(index: index, value: value))
            self.numbers[index] = 0
        }
        
        numbers.forEach({ self.numbers[$0] = 0 })
        numberOfTiles -= numbers.count
        
        clearedCount += 1
        if clearedCount.isMultiple(of: 100) {
            clearedCount = 0
            save()
        }
            
        return positions
    }
    
    public func hasValue(at index: Int) -> Bool {
        numbers[index] != 0
    }
    
    public func openMatch() -> Match? {
        MatchFinder.openMatch(in: numbers, random: random)
    }
    
    public func emptyLines(with pointers: Set<Int>) -> [CountableRange<Int>] {
        let points = Array(pointers.sorted().reversed())
        return EmptyLinesSearch.emptyRangesWithCheckPoints(points, field: numbers)
    }
    
    public func remove(lines removed: [CountableRange<Int>]) {
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
        numberOfLines = Int((CGFloat(numbers.count) / CGFloat(NumberOfColumns)).rounded(.up))
    }
    
    private func countTiles() {
        numberOfTiles = numbers.filter({ $0 != 0 }).count
    }
    
    public func restart(tiles: [Int]) {
        numbers = tiles
        save()
        updateStatus()
    }
    
    public func restartRegular() {
        numbers = DefaultStartBoard
        save()
        updateStatus()
    }
    
    public var gameEnded: Bool {
        for num in numbers {
            if num != 0 {
                return false
            }
        }
        
        return true
    }
    
    public func restore(positions: [Position]) {
        for position in positions {
            numbers[position.index] = position.value
        }
        numberOfTiles += positions.count
    }
    
    public func insert(positions: [Position]) {
        let sorted = positions.sorted(by: { $0.index < $1.index })
        sorted.forEach({ numbers.insert($0.value, at: $0.index) })
        updateLines()
    }
}
