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

import Autolayout
import Storyboards
import SwiftUI
import UIKit

public protocol MenuUIDelegate: AnyObject {
    func restart(_ lines: Int)
    func dismissMenu()
}

public class MenuUIViewController: UIViewController, StoryboardLoaded, MenuViewModelDelegate {
    public static var storyboardName: String {
        "MenuUI"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    public var gameWon = false
    public var delegate: MenuUIDelegate?
    
    private lazy var viewModel = MenuViewModel(delegate: self, gameWon: gameWon)
    private lazy var menuView = MenuView(viewModel: viewModel)
    private lazy var hosting = UIHostingController(rootView: menuView)
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
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
    
    func restart(lines: Int) {
        delegate?.restart(lines)
    }
    
    func rateApp() {
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/appName/id837173458?mt=8&action=write-review")!, options: [:])
    }
    
    func showFeedback() {
        guard  #available(iOS 14, *) else {
            return
        }
        
        //FeedbackService.present(on: self)
    }
}
