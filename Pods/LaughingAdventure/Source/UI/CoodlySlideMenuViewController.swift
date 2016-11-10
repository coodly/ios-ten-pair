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

#if os(iOS)

import UIKit

private extension Selector {
    static let openMenuTapped = #selector(CoodlySlideMenuViewController.openMenu)
}

open class CoodlySlideMenuViewController: SlideMenuController {
    private var containedNavigation: UINavigationController!
    private var menuController: MenuViewController!
    private var shown = false
    
    public var initialViewController: UIViewController!
    public var menuButton: UIBarButtonItem!

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shown {
            return
        }

        SlideMenuOptions.contentViewScale = 1

        shown = true

        containedNavigation = mainViewController as! UINavigationController
        menuController = leftViewController as! MenuViewController

        menuController.container = self

        presentRootController(initialViewController)
    }

    public func presentModalController(_ controller: UIViewController) {
        closeMenu()

        controller.modalPresentationStyle = UIModalPresentationStyle.formSheet
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(controller, animated: true, completion: nil)
    }
    
    public func presentRootController(_ controller: UIViewController) {
        closeMenu()

        controller.navigationItem.leftBarButtonItem = menuButton
        menuButton.target = self
        menuButton.action = .openMenuTapped

        if object_getClassName(containedNavigation.viewControllers.first) == object_getClassName(controller) {
            return
        }

        containedNavigation.setViewControllers([controller], animated: containedNavigation.viewControllers.count > 0)
    }

    func openMenu() {
        addLeftGestures()
        openLeft()
    }

    func closeMenu() {
        closeLeft();
        removeLeftGestures()
    }

    override open func track(_ trackAction: TrackAction) {
        if trackAction == .leftTapClose || trackAction == .leftFlickClose {
            removeLeftGestures()
        }
    }
}

#endif
