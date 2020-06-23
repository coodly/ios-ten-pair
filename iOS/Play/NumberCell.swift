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
    @IBOutlet private var container: UIView!
    private lazy var defaultBG = TileDefaultBackground()
    private lazy var noNumberBG = TileNoNumberBackground()
    private lazy var selectedBG = TileSelectedBackground()
    private lazy var successBG = TileSuccessBackground()
    private lazy var failureBG = TileFailureBackground()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [defaultBG, noNumberBG, selectedBG, successBG, failureBG].forEach() {
            view in
            
            container.addSubview(view)
            view.isOpaque = true
            view.translatesAutoresizingMaskIntoConstraints = false
            let padding = CGFloat(1)
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding).isActive = true
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: padding).isActive = true
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding).isActive = true
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding).isActive = true
        }
    }
        
    internal func show(number: Int, marker: NumberMarker) {
        if number == 0 {
            self.number.text = ""
            
            container.bringSubviewToFront(noNumberBG)
            return
        }
        
        self.number.text = String(describing: number)
        switch marker {
        case .standard:
            container.bringSubviewToFront(defaultBG)
        case .selection:
            container.bringSubviewToFront(selectedBG)
        case .success:
            container.bringSubviewToFront(successBG)
        case .failure:
            container.bringSubviewToFront(failureBG)
        }
    }
}
