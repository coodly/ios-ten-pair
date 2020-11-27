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
import SwiftUI

internal protocol MenuUIDelegate: class {
    func restart(_ lines: Int)
    func dismissMenu()
}

internal class MenuUIViewController: UIViewController, StoryboardLoaded, GDPRCheckConsumer, MenuViewModelDelegate {
    static var storyboardName: String {
        "MenuUI"
    }
    
    var gdprCheck: GDPRCheck?
    
    internal var gameWon = false
    internal var delegate: MenuUIDelegate?
    
    private lazy var dimView = OverlayBackgroundView()
    
    private lazy var viewModel = MenuViewModel(delegate: self)
    private lazy var menuView = MenuView(viewModel: viewModel)
    private lazy var hosting = UIHostingController(rootView: menuView)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        view.insertSubview(dimView, at: 0)
        dimView.pinToSuperviewEdges()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        dimView.addGestureRecognizer(tap)
        
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.pinToSuperviewEdges()
        hosting.view.backgroundColor = .clear
    }
    
    @objc fileprivate func dismissMenu() {
        delegate?.dismissMenu()
    }
    
    func resume() {
        delegate?.dismissMenu()
    }
}
