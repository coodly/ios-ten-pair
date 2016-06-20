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

private func contains<S: SequenceType where S.Generator.Element == Range<Int>>(array: S, value: Int) -> Bool {
    for range in array {
        if range.contains(value) {
            return true
        }
    }
    return false
}

class TenPairEmptyLinesSearch {
    class func emptyLinesWitaahCheckPoints(checks: [Int], field: [Int]) -> [Int] {
        let checkOne = checks[0]
        let checkTwo = checks[1]
        
        var result: [Int] = []
        
        let startOfRowOne = firstInRowForIndex(checkOne)
        if hasEmptyRowStartingAtIndex(startOfRowOne, field: field) {
            result.append(startOfRowOne / NumberOfColumns)
        }
        
        let startOfRowTwo = firstInRowForIndex(checkTwo)
        if startOfRowTwo != startOfRowOne && hasEmptyRowStartingAtIndex(startOfRowTwo, field: field) {
            result.append(startOfRowTwo / NumberOfColumns)
        }
        
        return result
    }
    
    class func emptyRangesWithCheckPoints(checks: [Int], field: [Int]) -> [Range<Int>] {
        var results = [Range<Int>]()
        
        let first = min(checks[0], checks[1])
        let second = max(checks[0], checks[1])
        
        let startForFirstRange = firstZeroRangeIndexStartingWith(first, inField: field)
        let firstRanges = possibleEmptyRanges(startForFirstRange, inField: field)
        results.appendContentsOf(firstRanges)
        
        if contains(results, value: second) {
            return results
        }
        
        if let last = results.sort({ $0.startIndex < $1.startIndex }).last where last.endIndex + NumberOfColumns > second {
            return results
        }

        let startForSecondRange = firstZeroRangeIndexStartingWith(second, inField: field)
        let seconfRanges = possibleEmptyRanges(startForSecondRange, inField: field)
        results.appendContentsOf(seconfRanges)

        return results
    }
    
    class func possibleEmptyRanges(startIndex: Int, inField field: [Int], rangeLength: Int = NumberOfColumns) -> [Range<Int>] {
        var result = [Range<Int>]()

        var count = 0
        var start = startIndex
        for index in startIndex..<field.count {
            count = count + 1

            guard field[index] == 0 else {
                break
            }
            
            if count == rangeLength {
                result.append(start...index)
                start = index + 1
                count = 0
            }
        }
        
        return result
    }
    
    class func firstZeroRangeIndexStartingWith(index: Int, inField field: [Int]) -> Int {
        var checked = index
        while checked > 0 {
            let value = field[checked]
            if value != 0 {
                return checked + 1
            }
            
            checked = checked - 1
        }
        
        return 0
    }
    
    class func firstInRowForIndex(index: Int) -> Int {
        return index - index % NumberOfColumns
    }
    
    class func hasEmptyRowStartingAtIndex(index: Int, field: [Int]) -> Bool {
        let rowEndIndex = index + NumberOfColumns
        if rowEndIndex > field.count {
            return false
        }
        
        for check in 0..<NumberOfColumns {
            let checked = field[check + index]
            if checked != 0 {
                return false
            }
        }
        
        return true
    }
}