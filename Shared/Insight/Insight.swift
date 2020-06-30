/*
* Copyright 2020 Coodly LLC
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
import CloudInsight
import CloudKit

internal class Insight {
    private let cloud: InsightClient
    internal init() {
        CloudInsight.Logging.set(logger: InsightLogger())
        cloud = CloudInsight.Insight.client(for: CKContainer(identifier: "iCloud.com.coodly.insight"))
    }
    
    internal func load() {
        cloud.loadEventsPush()
    }
}

private class InsightLogger: CloudInsight.Logger {
    func log<T>(_ object: T, file: String, function: String, line: Int) {
        Log.insight.debug(object, file: file, function: function, line: line)
    }
}
