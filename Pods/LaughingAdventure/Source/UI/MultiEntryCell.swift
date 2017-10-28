/*
 * Copyright 2017 Coodly LLC
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

open class MultiEntryCell: UITableViewCell, EntryValidated {
    public var validators = [UITextField: InputValidation]()

    @IBOutlet public var entryFields: [UITextField]!
    private lazy var sorted: [UITextField] = {
        return self.entryFields.sorted(by: {
            one, two in
        
            if one.frame.minX == two.frame.minX {
                return one.frame.minY < two.frame.minY
            } else {
                return one.frame.minX < two.frame.minX
            }
        })
    }()
    
    func firstField() -> UITextField? {
        return sorted.first
    }
    
    func nextEntry(after field: UITextField) -> UITextField? {
        guard let index = sorted.index(of: field) else {
            return nil
        }
        
        guard index < sorted.count - 1 else {
            return nil
        }
        
        let field = sorted[index + 1]
        
        if field.isUserInteractionEnabled  {
            return field
        }
        
        return nextEntry(after: field)
    }
}
