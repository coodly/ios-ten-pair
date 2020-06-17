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

internal enum MatchAction: String {
    case match
    case failure
}

internal class PlayField {
    private var numbers = [Int]()
    
    internal func load() {
        numbers = FieldSave.load()
    }
    
    private func save() {
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
    }
    
    internal func hasValue(at index: Int) -> Bool {
        numbers[index] != 0
    }
}
