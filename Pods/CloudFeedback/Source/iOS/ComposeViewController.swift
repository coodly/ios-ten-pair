/*
 * Copyright 2018 Coodly LLC
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

@available(iOS 13.0, *)
private extension Selector {
    static let sendPressed = #selector(ComposeViewController.sendPressed)
    static let cancelPressed = #selector(ComposeViewController.cancelPressed)
    static let keyboardChanged = #selector(ComposeViewController.keyboardChanged(notification:))
}

@available(iOS 13.0, *)
internal class ComposeViewController: UIViewController, TranslationConsumer {
    var translation: Translation!
    
    var entryHandler: ((String) -> ())!
    
    private var bottomSpacing: NSLayoutConstraint!
    private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        
        navigationItem.title = translation.input.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: .cancelPressed)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: translation.input.sendButton, style: .plain, target: self, action: .sendPressed)
        
        textView = UITextView(frame: view.bounds)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomSpacing = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomSpacing.isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        NotificationCenter.default.addObserver(self, selector: .keyboardChanged, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    @objc fileprivate func sendPressed() {
        guard let message = textView.text, message.hasValue() else {
            return
        }
        
        entryHandler(message)
    }
    
    @objc fileprivate func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func keyboardChanged(notification: Notification) {
        guard let info = notification.userInfo, let end = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyWindow = UIApplication.shared.keyWindow!
        let meInScreen = keyWindow.convert(view.frame, from: view)
        let frame = end.cgRectValue
        let keyboardInScreen = keyWindow.convert(frame, from: keyWindow.rootViewController!.view)
        let intersection = meInScreen.intersection(keyboardInScreen)
        bottomSpacing.constant = -intersection.height
        view.layoutIfNeeded()
    }
}
