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

public class Localized {
    public static let LanguageChangedNotification = Notification.Name(rawValue: "com.coodly.LanguageChangedNotification")

    static let sharedInstance = Localized()
    public var language = "en" {
        didSet {
            if oldValue != language {
                loadedBundle = bundleForLanguage(language)
                
                NotificationCenter.default.post(name: Localized.LanguageChangedNotification, object: nil)
            }
        }
    }
    
    private lazy var loadedBundle: Bundle = {
        return self.bundleForLanguage(self.language)
    }()
    
    public init() {
        
    }
    
    public func string(for key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: loadedBundle, value: key, comment: key)
    }
    
    private func bundleForLanguage(_ code: String) -> Bundle {
        return Bundle(path: Bundle.main.path(forResource: code, ofType: "lproj")!)!
    }
}