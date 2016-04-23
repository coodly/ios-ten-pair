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

let NumbersFieldWidth: Int = 9

class TenPairEmptyLinesSearch {
    class func emptyLinesWithCheckPoints(checks: [Int], field: [Int]) -> [Int] {
        let checkOne = checks[0]
        let checkTwo = checks[1]
        
        var result: [Int] = []
        
        let startOfRowOne = firstInRowForIndex(checkOne)
        if hasEmptyRowStartingAtIndex(startOfRowOne, field: field) {
            result.append(startOfRowOne / NumbersFieldWidth)
        }
        
        let startOfRowTwo = firstInRowForIndex(checkTwo)
        if startOfRowTwo != startOfRowOne && hasEmptyRowStartingAtIndex(startOfRowTwo, field: field) {
            result.append(startOfRowTwo / NumbersFieldWidth)
        }
        
        return result
    }
    
    class func firstInRowForIndex(index: Int) -> Int {
        return index - index % NumbersFieldWidth
    }
    
    class func hasEmptyRowStartingAtIndex(index: Int, field: [Int]) -> Bool {
        let rowEndIndex = index + NumbersFieldWidth
        if rowEndIndex > field.count {
            return false
        }
        
        for check in 0..<NumbersFieldWidth {
            let checked = field[check + index]
            if checked != 0 {
                return false
            }
        }
        
        return true
    }
}