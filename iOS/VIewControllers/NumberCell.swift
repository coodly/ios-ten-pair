/*
* Copyright 2020 Coodly LLC
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
import GameplayKit

internal enum NumberMarker: String {
    case standard
    case selection
    case success
    case failure
    
    internal static func from(state: PlayState?) -> NumberMarker {
        switch state {
        case is SelectingNumber:
            return .selection
        case is AnimatingSuccess:
            return .success
        case is AnimatingFailure:
            return .failure
        default:
            fatalError()
        }
    }
}

internal class NumberCell: UICollectionViewCell {
    @IBOutlet private var number: UILabel!
    @IBOutlet private var numberBackground: UIView!
    
    internal func show(number: Int, marker: NumberMarker) {
        if number == 0 {
            self.number.text = ""
            self.numberBackground.backgroundColor = UIColor.lightGray
            return
        }
        
        self.number.text = String(describing: number)
        switch marker {
        case .standard:
            numberBackground.backgroundColor = UIColor.blue
        case .selection:
            numberBackground.backgroundColor = UIColor.yellow
        case .success:
            numberBackground.backgroundColor = UIColor.green
        case .failure:
            numberBackground.backgroundColor = UIColor.red
        }
    }
}
