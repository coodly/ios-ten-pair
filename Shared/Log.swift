/*
 * Copyright 2017 Coodly LLC
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

import SWLogger

class Log {
    class func enable() {
        guard AppConfig.current.logs else {
            return
        }
        
        SWLogger.Log.add(output: ConsoleOutput())
        SWLogger.Log.add(output: FileOutput())
        
        SWLogger.Log.level = .debug
    }
    
    public static let insight = Logging(name: "Insight")
    public static let ads = Logging(name: "Ads")

    class func debug<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        SWLogger.Log.debug(object, file: file, function: function, line: line)
    }
}
