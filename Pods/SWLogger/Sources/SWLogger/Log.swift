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

    public static var level = Level.none
    
    private static let base = Logging(name: "App")
    
    public class func info<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        base.info(object, file: file, function: function, line: line)
    }

    public class func debug<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        base.debug(object, file: file, function: function, line: line)
    }
    
    public class func error<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        base.error(object, file: file, function: function, line: line)
    }

    public class func verbose<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        base.verbose(object, file: file, function: function, line: line)
    }
    
    public class func add(output: LogOutput) {
        Logger.sharedInstance.add(output: output)
    }
    
    internal static let logger = Logging(name: "SWLogger")
}
