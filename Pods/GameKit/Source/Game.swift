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
    public func radians(_ degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat(M_PI)) / 180.0
    }
}

open class Game: SKScene {
    #if os(iOS)
    var tapRecognizer: UITapGestureRecognizer?
    #endif
    
    fileprivate var screens = [GameView]()
    
    open func presentLoadingView(_ loadingScreen: GameLoadingView) {
        presentModalView(loadingScreen)
    }

    func presentModalView(_ modalView: GameView) {
        tagPresentedScreen(modalView)
        addChild(modalView)
        modalView.size = size
        modalView.anchorPoint = CGPoint(x: 0, y: 0)
        modalView.loadContent()
        modalView.positionContent()
    }
    
    open func presentModalScreen(_ screen: GameScreen) {
        showScreen(screen)
    }
    
    open func showScreen(_ screen: GameScreen) {
        tagPresentedScreen(screen)
        addChild(screen)
        screen.game = self
        screen.size = size
        screen.anchorPoint = CGPoint(x: 0, y: 0)
        screen.loadContent()
        screen.positionContent()
    }
    
    fileprivate func tagPresentedScreen(_ screen: GameView) {
        let usedZPos = screens.last?.zPosition ?? 0
        let zPos = usedZPos + 1
        screen.zPosition = zPos
        screens.append(screen)
    }
    
    open override func update(_ currentTime: TimeInterval) {
        for node in self.children {
            if !node.isKind(of: GameView.self) {
                continue
            }
            
            let view = node as! GameView
            view.update(currentTime)
        }
    }
    
    open override func didChangeSize(_ oldSize: CGSize) {
        positionContent(oldSize)
    }
    
    func positionContent(_ oldSize: CGSize) {
        for node in children {
            guard let view = node as? GameView else {
                continue
            }

            view.size = self.size
            view.positionContent()
        }
    }
    
    func handleTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        
        let screens = screensInArray(nodes)
        guard let topScreen = screens.first else {
            return
        }
        
        let screenNodes = topScreen.nodes(at: point)
        let sorted = screenNodes.sorted(by: {$0.zPosition > $1.zPosition})
        
        guard let button = findButtonInArray(sorted), let tapAction = button.action else {
            topScreen.handleTapAt(point)
            return
        }
        
        guard button.isEnabled() else {
            return
        }
        
        if button.touchDisables {
            button.disable()
        }
            
        run(tapAction)
    }
    
    func screensInArray(_ nodes: [SKNode]) -> [GameScreen] {
        var result = [GameScreen]()
        for node in nodes {
            guard let screen = node as? GameScreen else {
                continue
            }

            result.append(screen)
        }
        
        return result.sorted(by: {$0.zPosition > $1.zPosition})
    }
    
    func findButtonInArray(_ nodes: [AnyObject]) -> GameButton? {
        let usedNodes: [AnyObject]
        if #available(iOS 9, *) {
            usedNodes = nodes
        } else {
            usedNodes = nodes.reversed()
        }
        
        for node in usedNodes {
            if let button = node as? GameButton {
                return button
            }
        }
        
        return nil
    }
    
    open func dismissScreen(_ screen: GameScreen) {
        screen.unloadContent()
        screen.removeFromParent()
        
        if let index = screens.index(where: { $0 == screen }) {
            screens.remove(at: index)
        }
    }    
}

#if os(iOS)
private extension Selector {
    static let tapped = #selector(Game.tapped(_:))
}
    
extension Game {
    open override func didMove(to view: SKView) {
        let recognizer = UITapGestureRecognizer(target: self, action: .tapped)
        tapRecognizer = recognizer
        view.addGestureRecognizer(recognizer)
    }
    
    open override func willMove(from view: SKView) {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func tapped(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: self.view)
        let point = convertPoint(fromView: pointInView)
        handleTap(at: point)
    }
}
#else
    extension Game {
        override open func mouseDown(with theEvent: NSEvent) {
            /* Called when a mouse click occurs */
            
            let location = theEvent.location(in: self)
            handleTap(at: location)
        }
    }
#endif
