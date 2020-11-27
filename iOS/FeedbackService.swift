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

import Foundation
import CloudFeedback
import CloudKit

internal class FeedbackService {
    private static let shared = FeedbackService()
    
    private lazy var feedback: CloudFeedback.Feedback = {
        var translation = Translation()
        
        translation.conversations.title = NSLocalizedString("coodly.feedback.controller.title", comment: "")
        translation.conversations.loginMessage = NSLocalizedString("coodly.feedback.sign.in.message", comment: "")
        translation.conversations.notice = NSLocalizedString("coodly.feedback.header.message", comment: "")
        
        translation.notice.content = NSLocalizedString("coodly.feedback.response.notice", comment: "")
        
        translation.input.title = NSLocalizedString("coodly.feedback.message.compose.controller.title", comment: "")
        translation.input.sendButton = NSLocalizedString("coodly.feedback.message.compose.controller.send.button", comment: "")
        
        var styling = Styling.instance
        styling.mainColor = AppTheme.darkMainColor
        styling.greetingTextColor = UIColor.white
        styling.greetingTitle = NSLocalizedString("feedback.greeting.title", comment: "")
        styling.greetingMessage = NSLocalizedString("feedback.greeting.message", comment: "")
        styling.loginNotice = NSLocalizedString("feedback.login.notice", comment: "")

        return CloudFeedback.Feedback(container: CKContainer(identifier: "iCloud.com.coodly.feedback"), translation: translation, styling: styling)
    }()

    internal static func load() {
        CloudFeedback.Logging.set(logger: FeedbackLogger())
        shared.feedback.load()
    }

    
    static func hasMessage() -> Bool {
        shared.feedback.hasUnreadMessages
    }
        
    @available(iOS 14.0, *)
    static func present(on controller: UIViewController) {
        let navigation = UINavigationController(rootViewController: shared.feedback.client.feedbackController())
        navigation.modalPresentationStyle = .formSheet
        controller.present(navigation, animated: true, completion: nil)
    }
}

private class FeedbackLogger: CloudFeedback.Logger {
    func log<T>(_ object: T, file: String, function: String, line: Int) {
        Log.feedback.debug(object, file: file, function: function, line: line)
    }
}
