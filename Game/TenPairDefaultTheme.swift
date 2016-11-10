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
import SpriteKit

class TenPairDefaultTheme: TenPairTheme {
    init() {
        super.init(tintColor: SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1),
             backgroundColor: SKColor.white,
      defaultNumberTileColor: SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1),
             tileNumberColor: SKColor.white,
           selectedTileColor: SKColor(red: 0, green: 0.400, blue: 1.000, alpha: 1),
              errorTileColor: SKColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1),
            successTileColor: SKColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1),
           consumedTileColor: SKColor(white: 0.900, alpha: 1.000),
              menuTitleColor: SKColor.white,
   menuOptionBackgroundColor: SKColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1))
    }
}
