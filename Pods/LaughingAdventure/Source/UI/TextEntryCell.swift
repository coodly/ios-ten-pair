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

private extension Selector {
    static let dismissKeyboardPressed = #selector(TextEntryCell.dismissPressed)
}

open class TextEntryCell: DynamicFontReloadingTableViewCell {
    @IBOutlet public var entryField: UITextField!
    public var inputValidation: InputValidation?
    fileprivate var dismissButton: UIBarButtonItem?
    
    public func value() -> String {
        if let result = entryField.text {
            return result
        }
        
        return ""
    }
    
    func setReturnKeyType(_ type: UIReturnKeyType) {
        entryField.returnKeyType = type
        
        guard let _ = dismissButton else {
            return
        }
        
        if type == .next {
            dismissButton?.title = NSLocalizedString("coodly.text.field.next", comment: "")
        } else {
            dismissButton?.title = NSLocalizedString("coodly.text.field.done", comment: "")
        }
    }

    // MARK: - Decimal input
    #if os(iOS)
    open func decimalInput() {
        inputValidation = DecimalInputValidation()
        entryField.keyboardType = .decimalPad
        addAccessoryToolbar()
    }
    #endif
}

// MARK: - Done accessory
#if os(iOS)
public extension TextEntryCell {
    func addAccessoryToolbar()  {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        dismissButton = UIBarButtonItem(title: "", style: .plain, target: self, action: .dismissKeyboardPressed)
        toolbar.setItems([spacer, dismissButton!], animated: false)
        entryField.inputAccessoryView = toolbar
    }
}
#endif

fileprivate extension TextEntryCell {
    @objc fileprivate func dismissPressed() {
        _ = entryField.delegate?.textFieldShouldReturn?(entryField)
    }
}
