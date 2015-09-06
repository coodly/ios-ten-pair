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

public class Logger {
    public static let sharedInstance = Logger()
    private var logLevel:Log.Level = Log.Level.NONE
    private var outputs = [LogOutput]()
    
    public func setLogLevel(level:Log.Level) {
        logLevel = level
    }
    
    public func addOutput(output:LogOutput) {
        outputs.append(output)
    }
    
    internal func verbose(message:String) {
        logMessage(message, level: Log.Level.VERBOSE, prefix:"VERBOSE")
    }

    internal func debug(message:String) {
        logMessage(message, level: Log.Level.DEBUG, prefix:"DEBUG")
    }

    internal func info(message:String) {
        logMessage(message, level: Log.Level.INFO, prefix:"INFO")
    }

    internal func error(message:String) {
        logMessage(message, level: Log.Level.ERROR, prefix:"ERROR")
    }

    private func logMessage(message:String, level:Log.Level, prefix:String) {
        if level.rawValue < logLevel.rawValue {
            return
        }
        
        for output: LogOutput in outputs {
            output.printMessage("\(prefix) \(message)")
        }
    }
}