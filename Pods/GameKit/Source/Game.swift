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

import Foundation
import SpriteKit
import GLKit
import MessageUI
import UIKit

public extension SKNode {
    public func radians(degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat(M_PI)) / 180.0
    }
}

public class Game: SKScene, MFMailComposeViewControllerDelegate {
    var tapRecognizer: UITapGestureRecognizer?
    public var controller: UIViewController?
    private var screens = [GameView]()
    
    public func presentLoadingView(loadingScreen: GameLoadingView) {
        presentModalView(loadingScreen)
    }

    func presentModalView(modalView: GameView) {
        tagPresentedScreen(modalView)
        addChild(modalView)
        modalView.size = size
        modalView.anchorPoint = CGPointMake(0, 0)
        modalView.loadContent()
        modalView.positionContent()
    }
    
    public func presentModalScreen(screen: GameScreen) {
        showScreen(screen)
    }
    
    public func showScreen(screen: GameScreen) {
        tagPresentedScreen(screen)
        addChild(screen)
        screen.game = self
        screen.size = size
        screen.anchorPoint = CGPointMake(0, 0)
        screen.loadContent()
        screen.positionContent()
    }
    
    private func tagPresentedScreen(screen: GameView) {
        let usedZPos = screens.last?.zPosition ?? 0
        let zPos = usedZPos + 1
        screen.zPosition = zPos
        screens.append(screen)
    }
    
    public override func update(currentTime: NSTimeInterval) {
        for node in self.children {
            if !node.isKindOfClass(GameView) {
                continue
            }
            
            let view = node as! GameView
            view.update(currentTime)
        }
    }
    
    public override func didChangeSize(oldSize: CGSize) {
        positionContent(oldSize)
    }
    
    func positionContent(oldSize: CGSize) {
        for node in children {
            guard let view = node as? GameView else {
                continue
            }

            view.size = self.size
            view.positionContent()
        }
    }
    
    public override func didMoveToView(view: SKView) {
        let recognizer = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        tapRecognizer = recognizer
        view.addGestureRecognizer(recognizer)
    }
    
    public override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(self.view)
        let point = convertPointFromView(pointInView)
        let nodes = nodesAtPoint(point)
        
        let screens = screensInArray(nodes)
        guard let topScreen = screens.first else {
            return
        }
        
        let screenNodes = topScreen.nodesAtPoint(point)
        let sorted = screenNodes.sort({$0.zPosition > $1.zPosition})
        
        if let button = findButtonInArray(sorted), let tapAction = button.action {
            if button.touchDisables {
                button.userInteractionEnabled = false
            }
            
            runAction(tapAction)
        } else {
            topScreen.handleTapAt(point)
        }
    }
    
    func screensInArray(nodes: [SKNode]) -> [GameScreen] {
        var result = [GameScreen]()
        for node in nodes {
            guard let screen = node as? GameScreen else {
                continue
            }

            result.append(screen)
        }
        
        return result.sort({$0.zPosition > $1.zPosition})
    }
    
    func findButtonInArray(nodes: [AnyObject]) -> GameButton? {
        for node in nodes.reverse() {
            if let button = node as? GameButton {
                return button
            }
        }
        
        return nil
    }
    
    public func dismissScreen(screen: GameScreen) {
        screen.unloadContent()
        screen.removeFromParent()
        
        if let index = screens.indexOf({ $0 == screen }) {
            screens.removeAtIndex(index)
        }
    }
    
    public func sendEmail(email: String, subject: String = "") {
        if !MFMailComposeViewController.canSendMail() {
            presentEmailConfigurationAlert()
            return
        }
        
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setToRecipients([email])
        mailController.setSubject(subject)
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")! as! String
        mailController.setMessageBody("\n\n\n| App version: \(appVersion) |", isHTML: false)
        controller!.presentViewController(mailController, animated: true, completion: nil)
    }
    
    func presentEmailConfigurationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("CDYFeedback.cant.send.email.title", comment: ""), message: NSLocalizedString("CDYFeedback.cant.send.email.message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("CDYFeedback.cant.send.email.alert.dismiss.button", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
        if let presentOn = controller {
           presentOn.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func presentEmailSendErrorAlert(onController: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("CDYFeedback.email.not.sent.error.title", comment: ""), message: NSLocalizedString("CDYFeedback.email.not.sent.error.message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("CDYFeedback.email.not.sent.error.dismiss.button", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
        onController.presentViewController(alert, animated: true, completion: nil)
    }
    
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if let _ = error {
            presentEmailSendErrorAlert(controller)
            return
        }

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
