/*
 * Copyright 2018 Coodly LLC
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

import CloudKit

private extension Selector {
    static let didBecomeActive = #selector(Insight.didBecomeActive)
    static let didEnterBackground = #selector(Insight.didEnterBackground)
}


public protocol InsightClient {
    func loadEventsPush()
    func log(event: String, values: [String: String])
}

extension Insight: InsightClient {    
    public static func client(for container: CKContainer) -> InsightClient {
        return Insight(container: container)
    }
    
    public func loadEventsPush() {
        inject(into: self)
        
        var operations = [Operation]()
        operations.add(operation: LoadPersistenceOperation())
        operations.add(operation: ResolveUserOperation())
        operations.add(operation: ResetFauluresOperation())
        operations.add(operation: MarkDeviceOperation(create: false))
        let loadPush = BlockOperation() {
            self.push.load()
        }
        operations.add(operation: loadPush)
        
        operations.forEach({ inject(into: $0) })
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        NotificationCenter.default.addObserver(self, selector: .didBecomeActive, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .didEnterBackground, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc fileprivate func didBecomeActive() {
        Logging.log("Did become active")
        log(event: .sessionStart, values: [.sessionId: sessionID.uuidString, .appVersion: appVersion])
    }

    @objc fileprivate func didEnterBackground() {
        Logging.log("Did enter background")
        log(event: .sessionEnd, values: [.sessionId: sessionID.uuidString])
        sessionID = UUID()
    }
    
    public func log(event: String, values: [String: String] = [:]) {
        let op = LogEventOperation(name: event, values: values)
        inject(into: op)
        queue.addOperation(op)
    }

}
