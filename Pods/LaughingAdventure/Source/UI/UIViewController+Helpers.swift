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

import UIKit

private extension Selector {
    static let closeModalPressed = #selector(UIViewController.closeModal)
}

public extension UIViewController {
    public func pushMaybeModally(_ controller: UIViewController, closeButtonTitle: String = NSLocalizedString("modally.presented.close.button.title", comment: "")) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController!.pushViewController(controller, animated: true)
        } else {
            let navigation = UINavigationController(rootViewController: controller)
            if let _ = controller.navigationItem.leftBarButtonItem {
                Logging.log("Close button will not be added")
            } else {
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(title: closeButtonTitle, style: .plain, target: self, action: .closeModalPressed)
            }
            #if os(iOS)
            navigation.modalPresentationStyle = .formSheet
            #endif
            navigation.modalTransitionStyle = .crossDissolve
            present(navigation, animated: true, completion: nil)
        }
    }
    
    public func popOrDismiss() {
        if navigationController!.viewControllers.count == 1 {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func closeModal() {
        dismiss(animated: true, completion: nil)
    }
}

public protocol QuickAlertPresenter {
    func presentAlert(_ title: String, message: String, dismissButtonTitle: String)
    func presentErrorAlert(_ title: String, error: NSError, dismissButtonTitle: String)
}

public extension QuickAlertPresenter where Self: UIViewController {
    func presentAlert(_ title: String, message: String, dismissButtonTitle: String = NSLocalizedString("generic.button.title.ok", comment: "")) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentErrorAlert(_ title: String, error: NSError, dismissButtonTitle: String = NSLocalizedString("generic.button.title.ok", comment: "")) {
        presentAlert(title, message: error.localizedDescription, dismissButtonTitle: dismissButtonTitle)
    }
}
