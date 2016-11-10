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

private let HasFullVersionKey = "HasFullVersionKey"

protocol FullVersionHandler {
    func showFullVersionPurchase() -> Bool
    func fullVersionUnlocked() -> Bool
    func markFullVersionUnlocked()
}

#if os(iOS)
import Locksmith
import SWLogger

extension FullVersionHandler {
    func showFullVersionPurchase() -> Bool {
        return true
    }
    
    func fullVersionUnlocked() -> Bool {
        guard let data = Locksmith.loadDataForUserAccount(userAccount: FullVersionKey) else {
            return false
        }
        
        guard let has = data[HasFullVersionKey] as? Bool, has else {
            return false
        }
        
        return has
    }
    
    func markFullVersionUnlocked() {
        do {
            let data = [HasFullVersionKey: true]
            try Locksmith.saveData(data: data, forUserAccount: FullVersionKey)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: CheckAppFullVersionNotification), object: nil)
            }
        } catch let error as NSError {
            Log.error("Mark full version error: \(error)")
        }
    }
    
    func removeFullVersion() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: FullVersionKey)
        } catch let error as NSError {
            Log.error("Remove IAP error \(error)")
        }
    }
}
#else
    extension FullVersionHandler {
        func showFullVersionPurchase() -> Bool {
            return false
        }

        func fullVersionUnlocked() -> Bool {
            return true
        }
        
        func markFullVersionUnlocked() {
            
        }
    }
#endif
