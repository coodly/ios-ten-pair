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

import Foundation
import CloudKit
import CoreDataPersistence
import KeychainAccess

internal protocol Injector {
    func inject(into object: AnyObject)
}

internal extension Injector {
    func inject(into object: AnyObject) {
        Injection.shared.inject(into: object)
    }
}

internal class Injection {
    internal static let shared = Injection()
    
    internal var container: CKContainer?
    private lazy var accessibility: Accessibility = {
        #if targetEnvironment(macCatalyst)
            return .afterFirstUnlockThisDeviceOnly
        #else
            return .alwaysThisDeviceOnly
        #endif
    }()
    private lazy var keychain = Keychain(service: "com.coodly.insight").accessibility(self.accessibility)
    private lazy var push: DataPush = {
        let push = DataPush()
        inject(into: push)
        return push
    }()
    
    private var queueObservation: NSKeyValueObservation?
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.name = "Insight queue"
        queue.maxConcurrentOperationCount = 1
        queueObservation = queue.observe(\.operationCount) {
            localQueue, _ in
            
            self.pendingOperations = localQueue.operationCount
        }
        return queue
    }()
    private var pendingOperations = 0 {
        didSet {
            if oldValue == 0, pendingOperations > 0 {
                self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask()
            } else if pendingOperations == 0 {
                self.backgroundTaskIdentifier = nil
            }
        }
    }
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier? {
        didSet {
            if let value = backgroundTaskIdentifier {
                Logging.log("Insight: start task: \(value)")
            }

            guard let previous = oldValue else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                Logging.log("Insight: end task: \(previous)")
                UIApplication.shared.endBackgroundTask(previous)
            }
        }
    }
    
    private lazy var persistence: CorePersistence = {
        let frameworkBundle = Bundle(for: Insight.self)
        let modelBundleURL = frameworkBundle.url(forResource: "CloudInsight", withExtension: "bundle")!
        let modelBundle = Bundle(url: modelBundleURL)!
        
        return CorePersistence(modelName: "CloudInsight", identifier: "com.coodly.insight", bundle: modelBundle, in: persistenceFolder, wipeOnConflict: true)
    }()
    internal var persistenceFolder: FileManager.SearchPathDirectory = .cachesDirectory
    
    internal var userRecordID: CKRecord.ID?
    
    fileprivate func inject(into object: AnyObject) {
        if var consumer = object as? ContainerConsumer {
            consumer.insightContainer = container!
        }
        
        if var consumer = object as? PersistenceConsumer {
            consumer.persistence = persistence
        }
        
        if var consumer = object as? InsightQueueConsumer {
            consumer.queue = queue
        }
        
        if var consumer = object as? KeychainConsumer {
            consumer.keychain = keychain
        }
        
        if var consumer = object as? UserRecordConsumer {
            consumer.userRecordID = userRecordID
        }
        
        if var consumer = object as? DataPushConsumer {
            consumer.push = push
        }
    }
}
