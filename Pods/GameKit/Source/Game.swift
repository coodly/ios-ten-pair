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
#if os(iOS)
import UIKit
#endif

public extension SKNode {
    public func radians(degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat(M_PI)) / 180.0
    }
}

public class Game: SKScene {
    #if os(iOS)
    var tapRecognizer: UITapGestureRecognizer?
    #endif
    
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
    
    func handleTap(at point: CGPoint) {
        let nodes = nodesAtPoint(point)
        
        let screens = screensInArray(nodes)
        guard let topScreen = screens.first else {
            return
        }
        
        let screenNodes = topScreen.nodesAtPoint(point)
        let sorted = screenNodes.sort({$0.zPosition > $1.zPosition})
        
        guard let button = findButtonInArray(sorted), tapAction = button.action else {
            topScreen.handleTapAt(point)
            return
        }
        
        guard button.isEnabled() else {
            return
        }
        
        if button.touchDisables {
            button.disable()
        }
            
        runAction(tapAction)
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
        let usedNodes: [AnyObject]
        if #available(iOS 9, *) {
            usedNodes = nodes
        } else {
            usedNodes = nodes.reverse()
        }
        
        for node in usedNodes {
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
}

#if os(iOS)
private extension Selector {
    static let tapped = #selector(Game.tapped(_:))
}
    
extension Game {
    public override func didMoveToView(view: SKView) {
        let recognizer = UITapGestureRecognizer(target: self, action: .tapped)
        tapRecognizer = recognizer
        view.addGestureRecognizer(recognizer)
    }
    
    public override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(self.view)
        let point = convertPointFromView(pointInView)
        handleTap(at: point)
    }
}
#else
    extension Game {
        override public func mouseDown(theEvent: NSEvent) {
            /* Called when a mouse click occurs */
            
            let location = theEvent.locationInNode(self)
            handleTap(at: location)
        }
    }
#endif
