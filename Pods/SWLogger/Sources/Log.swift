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

public class Log {
    public enum Level: Int {
        case verbose = 0, debug, info, error, none
    }

    public static var logLevel = Level.none
    
    public class func info<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .info)
    }

    public class func debug<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .debug)
    }
    
    public class func error<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .error)
    }

    public class func verbose<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .verbose)
    }
    
    public class func add(output: LogOutput) {
        Logger.sharedInstance.add(output: output)
    }
}
