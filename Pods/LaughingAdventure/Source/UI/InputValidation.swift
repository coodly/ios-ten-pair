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

import UIKit

public protocol InputValidation {
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
}

public class DecimalInputValidation: InputValidation {
    public init() {
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        
        if string != "." && string != "," {
            return true
        }
        
        guard let original = textField.text else {
            return true
        }
        
        if let _ = original.range(of: ".") {
            return false
        }
        
        guard let range = original.range(from: range) else {
            return true
        }
        
        var replaced = original
        replaced.replaceSubrange(range, with: ".")
        textField.text = replaced
        return false
    }
}
