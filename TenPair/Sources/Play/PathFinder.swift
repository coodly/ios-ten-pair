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

public class PathFinder {
  public class func hasClearPath(_ indexes: [Int], inField: [Int]) -> Bool {
    let one = indexes[0]
    let two = indexes[1]
        
    let first = min(one, two)
    let second = max(one, two)
        
    if first + 1 == second {
      return true
    }
        
    if first + NumberOfColumns == second {
      return true
    }
        
    if onSameVerticalLine(first, secondIndex: second) {
      var index = first + NumberOfColumns
      while index < second {
        let checked = inField[index]
                
        if checked != 0 {
          return false
        }
                
        index += NumberOfColumns
      }
      return true
    }
        
    for index in (first + 1)..<second {
      let check = inField[index]
            
      if check != 0 {
        return false
      }
    }
        
    return true
  }
    
  private class func onSameVerticalLine(_ firstIndex: Int, secondIndex: Int) -> Bool {
    let firstMod = firstIndex % NumberOfColumns
    let secondMod = secondIndex % NumberOfColumns
    return firstMod == secondMod
  }
}
