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
    static let dismiss = #selector(FeedbackNoticeViewController.dismissPressed)
}

@available(iOS 13.0, *)
class FeedbackNoticeViewController: UIViewController, TranslationConsumer {
    var translation: Translation!
    
    private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .dismiss)
        
        textView = UITextView(frame: view.bounds)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.text = translation.notice.content
        textView.textAlignment = .justified
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc fileprivate func dismissPressed() {
        dismiss(animated: true, completion: nil)
    }
}
