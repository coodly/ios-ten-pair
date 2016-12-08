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

class MenuPresentationContainer: ScrollViewContained {
    var items: [MenuButton] = []
    var maxWidth: CGFloat = 0
    let menuSpacing: CGFloat = 10
    
    func append(_ item: MenuButton) {
        item.anchorPoint = CGPoint.zero
        maxWidth = max(item.size.width, maxWidth)
        items.append(item)
        addGameView(item)
    }
    
    override func positionContent() {
        super.positionContent()

        var yOffset: CGFloat = 0
        for button in Array(items.reversed()) {
            let positionX = (maxWidth - button.size.width) / 2
            button.position = CGPoint(x: positionX, y: yOffset)
            yOffset += button.size.height
            yOffset += menuSpacing
        }
        yOffset -= menuSpacing
        
        size = CGSize(width: maxWidth, height: yOffset)
        scrollView!.contentSizeChanged()
    }
}
