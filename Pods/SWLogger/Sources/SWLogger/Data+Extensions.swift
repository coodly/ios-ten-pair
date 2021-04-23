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

import Foundation

extension Data {
    internal func tail(lines: Int) -> Data {
        let newLine = "\n".data(using: .utf8)!

        var lineNo = 0
        var pos = self.count - 1
        repeat {
            // Find next newline character:
            guard let range = self.range(of: newLine, options: [ .backwards ], in: 0..<pos) else {
                return self
            }
            lineNo += 1
            pos = range.lowerBound
        } while lineNo < lines
        
        return self.subdata(in: pos..<self.count)

    }
}
