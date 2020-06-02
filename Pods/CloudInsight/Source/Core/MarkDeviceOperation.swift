/*
 * Copyright 2019 Coodly LLC
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
import KeychainAccess
import CoreData
import CloudKit

private typealias Dependencies = PersistenceConsumer & KeychainConsumer & InsightQueueConsumer & UserRecordConsumer

internal class MarkDeviceOperation: ConcurrentOperation, Dependencies, Injector {
    var persistence: CorePersistence!
    var keychain: Keychain!
    var queue: OperationQueue!
    var userRecordID: CKRecord.ID?
    
    private let createMissingDevice: Bool
    internal init(create: Bool) {
        createMissingDevice = create
    }
    
    override func main() {
        inject(into: self)
        
        guard userRecordID != nil else {
            Logging.log("No user")
            self.finish()
            return
        }
        
        persistence.write() {
            context in
            
            checkDevice(in: context)
        }
    }
    
    private func checkDevice(in context: NSManagedObjectContext) {
        Logging.log("Check device")
        
        defer {
            finish()
        }
        
        let deviceId = keychain.deviceId
        if let device = context.device(with: deviceId) {
            Logging.log("Update existing device")
            updateDetails(on: device)
        } else if createMissingDevice {
            Logging.log("Create device")
            let saved = context.createDevice(with: deviceId)
            updateDetails(on: saved)
        } else {
            Logging.log("Refresh devices")
            var operations = [Operation]()
            operations.add(operation: RefreshDeviceOperation(deviceId: deviceId))
            operations.add(operation: MarkDeviceOperation(create: true))
            
            operations.forEach({ inject(into: $0) })
            queue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
    private func updateDetails(on device: Device) {
        Logging.log("Update details on \(device)")
        let changed = device.refresh(model: UIDevice.current.modelName, version: UIDevice.current.systemVersion)
        if changed {
            Logging.log("Device sync needed")
            device.markSyncNeed()
        }
    }
}

// https://stackoverflow.com/questions/11197509/how-to-get-device-make-and-model-on-ios/11197770#11197770
extension UIDevice {
    fileprivate var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

