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

internal class Logger {
    internal static let sharedInstance = Logger()
    internal var outputs = [LogOutput]()
        
    internal func add(output: LogOutput) {
        outputs.append(output)
    }
    
    internal func log<T>(_ object: T, file: String, function: String, line: Int, level: Log.Level) {
        if level.rawValue < Log.logLevel.rawValue {
            return
        }

        let time = timeFormatter.string(from: Date())
        let levelString = levelToString(level)
        let fileURL = URL(fileURLWithPath: file, isDirectory: false)
        let cleanedFile = fileURL.lastPathComponent
        let message = "\(time) - \(levelString) - \(cleanedFile).\(function):\(line) - \(object)"

        for output: LogOutput in outputs {
            output.printMessage(message)
        }
    }
    
    private func levelToString(_ level: Log.Level) -> String {
        switch(level) {
        case .error:
            return "E"
        case .info:
            return "I"
        case .debug:
            return "D"
        case .verbose:
            return "V"
        default:
            return ""
        }
    }
    
    private lazy var timeFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
