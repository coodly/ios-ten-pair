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
        case VERBOSE = 0, DEBUG, INFO, ERROR, NONE
    }

    public static var logLevel = Level.NONE
    
    public class func info<T>(object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .INFO)
    }

    public class func debug<T>(object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .DEBUG)
    }
    
    public class func error<T>(object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .ERROR)
    }

    public class func verbose<T>(object: T, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.sharedInstance.log(object, file: file, function: function, line: line, level: .VERBOSE)
    }
    
    public class func addOutput(output:LogOutput) {
        Logger.sharedInstance.addOutput(output)
    }
}