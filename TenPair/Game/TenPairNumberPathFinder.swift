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

let columns: Int = 9

class TenPairNumberPathFinder {
    class func hasClearPath(indexes: [Int], inField: [Int]) -> Bool {
        let one = indexes[0]
        let two = indexes[1]
        
        let first = min(one, two)
        let second = max(one, two)
        
        if first + 1 == second {
            return true
        }
        
        if first + columns == second {
            return true
        }
        
        if onSameHorisontalLine(first, secondIndex: second) {
            for var index = first + 1; index < second; index++ {
                let checked = inField[index]
                if checked != 0 {
                    return false
                }
            }
            
            return true
        }
        
        if onSameVerticalLine(first, secondIndex: second) {
            for var index = first + columns; index < second; index += columns {
                let checked = inField[index]
                
                if checked != 0 {
                    return false
                }
            }
            
            return true
        }
        
        for var index = first + 1; index < second; index++ {
            let check = inField[index]
            
            if check != 0 {
                return false
            }
        }
        
        return true
    }
    
    class func onSameVerticalLine(firstIndex: Int, secondIndex: Int) -> Bool {
        let firstMod = firstIndex % columns
        let secondMod = secondIndex % columns
        return firstMod == secondMod
    }

    class func onSameHorisontalLine(firstIndex: Int, secondIndex: Int) -> Bool {
        let lineOne = firstIndex / columns
        let lineTwo = secondIndex / columns
        return lineOne == lineTwo
    }
}