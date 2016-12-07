/*
 * Copyright 2016 Coodly LLC
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

#if os(iOS)
private extension Selector {
    static let dismiss = #selector(FeedbackNoticeViewController.dismissPressed)
}

class FeedbackNoticeViewController: UIViewController {
    private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .dismiss)
        
        textView = UITextView(frame: view.bounds)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.text = NSLocalizedString("coodly.feedback.response.notice", comment: "")
        view.addSubview(textView)
        
        let views: [String: AnyObject] = ["text": textView]
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[text]|", options: [], metrics: nil, views: views)
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[text]|", options: [], metrics: nil, views: views)
        
        view.addConstraints(vertical + horizontal)
    }
    
    @objc fileprivate func dismissPressed() {
        dismiss(animated: true, completion: nil)
    }
}
#endif
