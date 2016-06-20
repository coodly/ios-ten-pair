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
    func fullVersionUnlocked() -> Bool
    func markFullVersionUnlocked()
}

#if os(iOS)
import Locksmith
import SWLogger

extension FullVersionHandler {
    func fullVersionUnlocked() -> Bool {
        guard let data = Locksmith.loadDataForUserAccount(FullVersionKey) else {
            return false
        }
        
        guard let has = data[HasFullVersionKey] as? Bool where has else {
            return false
        }
        
        return has
    }
    
    func markFullVersionUnlocked() {
        do {
            let data = [HasFullVersionKey: true]
            try Locksmith.saveData(data, forUserAccount: FullVersionKey)
            onMainThread() {
                NSNotificationCenter.defaultCenter().postNotificationName(CheckAppFullVersionNotification, object: nil)
            }
        } catch let error as NSError {
            Log.error("Mark full version error: \(error)")
        }
    }
    
    func removeFullVersion() {
        do {
            try Locksmith.deleteDataForUserAccount(FullVersionKey)
        } catch let error as NSError {
            Log.error("Remove IAP error \(error)")
        }
    }
}
#else
    extension FullVersionHandler {
        func fullVersionUnlocked() -> Bool {
            return true
        }
        
        func markFullVersionUnlocked() {
            
        }
    }
#endif
