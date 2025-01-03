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

import Config
import Foundation

private func contains<S: Sequence>(_ array: S, value: Int) -> Bool where S.Iterator.Element == CountableRange<Int> {
  for range in array {
    if range.contains(value) {
      return true
    }
  }
  return false
}

public class EmptyLinesSearch {
  public class func emptyRangesWithCheckPoints(_ checks: [Int], field: [Number]) -> [CountableRange<Int>] {
    var results = [CountableRange<Int>]()
        
    let first = min(checks[0], checks[1])
    let second = max(checks[0], checks[1])
        
    let startForFirstRange = firstZeroRangeIndexStartingWith(first, inField: field)
    let firstRanges = possibleEmptyRanges(startForFirstRange, inField: field)
    results.append(contentsOf: firstRanges)
        
    if contains(results, value: second) {
      return results
    }
        
    if let last = results.sorted(by: { $0.lowerBound < $1.lowerBound }).last, last.upperBound + NumberOfColumns > second {
      return results
    }
        
    let startForSecondRange = firstZeroRangeIndexStartingWith(second, inField: field)
    let secondRanges = possibleEmptyRanges(startForSecondRange, inField: field)
    results.append(contentsOf: secondRanges)
        
    return results
  }
    
  private class func possibleEmptyRanges(_ startIndex: Int, inField field: [Number], rangeLength: Int = NumberOfColumns) -> [CountableRange<Int>] {
    var result = [CountableRange<Int>]()
        
    var count = 0
    var start = startIndex
    for index in startIndex..<field.count {
      count = count + 1
            
      guard field[index].value == 0 else {
        break
      }
            
      if count == rangeLength {
        result.append(start..<index+1)
        start = index + 1
        count = 0
      }
    }
        
    return result
  }
    
  private class func firstZeroRangeIndexStartingWith(_ index: Int, inField field: [Number]) -> Int {
    var checked = index
    while checked > 0 {
      let value = field[checked]
      if value.value != 0 {
        return checked + 1
      }
            
      checked = checked - 1
    }
        
    return 0
  }
    
  private class func firstInRowForIndex(_ index: Int) -> Int {
    return index - index % NumberOfColumns
  }
    
  private class func hasEmptyRowStartingAtIndex(_ index: Int, field: [Int]) -> Bool {
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
