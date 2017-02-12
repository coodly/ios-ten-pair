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
    private lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.name = "Menu scroll view"
        scrollView.verticallyCentered = true
        return scrollView
    }()
    open var itemSpacing: CGFloat {
        return 10
    }
    open var itemSize: CGSize {
        return CGSize(width: size.width - 40, height: 40)
    }
    private var options: [Button] = []
    private lazy var container: MenuOptionsContainer = {
        let container = MenuOptionsContainer()
        container.name = "Menu options container"
        return container
    }()
    
    override func beforeLoad() {
        name = "Menu screen"
        add(fullSized: scrollView)
        container.itemSize = itemSize
        container.itemSpacing = itemSpacing
        scrollView.present(container)
    }
    
    public func append(_ option: Button) {
        options.append(option)
        container.addSubview(option)
    }    
}
