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
import CoreDataPersistence
import CoreData
import CloudKit

public extension Notification.Name {
    static let feedbackNewMessageReceived = Notification.Name(rawValue: "feedbackNewMessageReceived")
}

private extension Selector {
    static let checkForMessages = #selector(FeedbackInjection.checkForMessages)
    static let checkCloudAvailability = #selector(FeedbackInjection.checkCloudAvailability)
}

internal protocol FeedbackInjector {
    func inject(into: AnyObject)
}

internal extension FeedbackInjector {
    func inject(into: AnyObject) {
        FeedbackInjection.sharedInstance.inject(into: into)
    }
}

internal class FeedbackInjection {
    internal static let sharedInstance = FeedbackInjection()
    
    private lazy var persistence: CorePersistence = {
        let persistence = CorePersistence(modelName: "Feedback", identifier: "com.coodly.feedback", in: .cachesDirectory, wipeOnConflict: true)
        persistence.managedObjectModel = NSManagedObjectModel.createFeedbackV1()
        return persistence
    }()
    internal var feedbackContainer: CKContainer!
    private var cloudAvailable = false {
        didSet {
            guard cloudAvailable else {
                return
            }
            
            checkForMessages()
        }
    }
    private lazy var messagesPush = MessagesPush()
    private lazy var platform: String = {
        let device = self.platformName() ?? "unknown"
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let systemVersion = UIDevice.current.systemVersion
        return "\(device)|\(systemVersion)|\(appVersion)(\(appBuild))"
    }()
    internal var translation = Translation()
    internal var styling = Styling()
    
    private init() {}
    
    internal func setUp() {
        inject(into: messagesPush)
        checkCloudAvailability()
        
        Logging.log("Add app life listener")
        NotificationCenter.default.addObserver(self, selector: .checkForMessages, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .checkCloudAvailability, name: .CKAccountChanged, object: nil)
    }
    
    fileprivate func inject(into: AnyObject) {
        if var consumer = into as? PersistenceConsumer {
            consumer.persistence = persistence
        }
        
        if var consumer = into as? FeedbackContainerConsumer {
            consumer.feedbackContainer = feedbackContainer
        }
        
        if var consumer = into as? PlatformConsumer {
            consumer.platform = platform
        }
        
        if var consumer = into as? CloudAvailabilityConsumer {
            consumer.cloudAvailable = cloudAvailable
        }
        
        if var consumer = into as? TranslationConsumer {
            consumer.translation = translation
        }
        
        if var consumer = into as? StylingConsumer {
            consumer.styling = styling
        }
    }
    
    //https://github.com/schickling/Device.swift/blob/master/Device/UIDeviceExtension.swift
    private func platformName() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8 , value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return identifier
    }
    
    @objc fileprivate func checkCloudAvailability() {
        feedbackContainer.accountStatus() {
            status, error in
            
            Logging.log("Account status: \(status.rawValue) - \(String(describing: error))")
            Logging.log("Available: \(status == .available)")
            self.cloudAvailable = status == .available
        }
    }
    
    @objc fileprivate func checkForMessages() {
        Logging.log("Check for feedback messages")
        let refresh = FeedbackRefresh()
        inject(into: refresh)
        refresh.refresh() {
            hasMessages in
            
            if hasMessages {
                DispatchQueue.main.async {
                    Logging.log("Post new messages notification")
                    NotificationCenter.default.post(name: .feedbackNewMessageReceived, object: nil)
                }
            }
        }
    }
}

internal func injected<T: AnyObject>(_ object: T) -> T {
    FeedbackInjection.sharedInstance.inject(into: object)
    return object
}
