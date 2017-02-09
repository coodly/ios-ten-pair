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

import SpriteKit

open class MenuScreen: Screen {
    private var scrollView: ScrollView?
    open var itemSpacing: CGFloat {
        return 10
    }
    open var itemSize: CGSize {
        return CGSize(width: size.width - 40, height: 40)
    }
    private var options: [Button] = []
    private var container = ScrollViewContained()
    
    override func beforeLoad() {
        scrollView = ScrollView()
        add(fullSized: scrollView!)
    }
    
    override func afterLoad() {
        
    }
    
    public func append(_ option: Button) {
        options.append(option)
        container.addChild(option)
    }
    
    override func sizeChanged() {
        super.sizeChanged()
        
        var positionY: CGFloat = 0
        for item in options.reversed() {
            positionY += (positionY > 0 ? itemSpacing : 0)
            
            item.anchorPoint = .zero
            item.position = CGPoint(x: 0, y: positionY)
            item.size = itemSize
            
            positionY += itemSize.height
        }
        
        container.size = CGSize(width: itemSize.width, height: positionY)
        scrollView?.present(container)
        container.color = .red
    }
}
