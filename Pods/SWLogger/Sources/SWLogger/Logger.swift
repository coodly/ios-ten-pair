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
    private var cleaned = [String: String]()
        
    private let queue = DispatchQueue(label: "com.coodly.logging.queue")
    
    internal func add(output: LogOutput) {
        outputs.append(output)
    }
    
    internal func log<T>(message: Message<T>) {
        queue.sync {
            guard message.level.rawValue >= Log.level.rawValue else {
                return
            }

            let time = timeFormatter.string(from: message.time)
            let levelString = levelToString(message.level)
            let cleanedFile = cleaned(path: message.file)
            let message = "\(time) - \(message.logger) - \(levelString) - \(cleanedFile).\(message.function):\(message.line) - \(message.object)"

            for output: LogOutput in outputs {
                output.printMessage(message)
            }
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
    
    private func cleaned(path: String) -> String {
        if let existing = self.cleaned[path] {
            return existing
        }
        
        let fileURL = URL(fileURLWithPath: path, isDirectory: false)
        let cleanedFile = fileURL.lastPathComponent
        self.cleaned[path] = cleanedFile
        return cleanedFile
    }
    
    private lazy var timeFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
