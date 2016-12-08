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
    
    fileprivate var screens = [View]()
    
    open func present(loading view: LoadingView) {
        presentModal(view: view)
    }

    func presentModal(view view: View) {
        tagPresentedScreen(view)
        addChild(view)
        view.size = size
        view.anchorPoint = CGPoint(x: 0, y: 0)
        view.loadContent()
        view.positionContent()
    }
    
    open func presentModal(screen screen: Screen) {
        show(screen)
    }
    
    open func show(_ screen: Screen) {
        tagPresentedScreen(screen)
        addChild(screen)
        screen.game = self
        screen.size = size
        screen.anchorPoint = CGPoint(x: 0, y: 0)
        screen.loadContent()
        screen.positionContent()
    }
    
    fileprivate func tagPresentedScreen(_ screen: View) {
        let usedZPos = screens.last?.zPosition ?? 0
        let zPos = usedZPos + 1
        screen.zPosition = zPos
        screens.append(screen)
    }
    
    open override func update(_ currentTime: TimeInterval) {
        for node in self.children {
            guard let view = node as? View else {
                continue
            }
            
            view.update(currentTime)
        }
    }
    
    open override func didChangeSize(_ oldSize: CGSize) {
        positionContent(oldSize)
    }
    
    func positionContent(_ oldSize: CGSize) {
        for node in children {
            guard let view = node as? View else {
                continue
            }

            view.size = self.size
            view.positionContent()
        }
    }
    
    func handleTap(at point: CGPoint) {
        let nodes = self.nodes(at: point)
        
        let screens = self.screens(in: nodes)
        guard let topScreen = screens.first else {
            return
        }
        
        let screenNodes = topScreen.nodes(at: point)
        let sorted = screenNodes.sorted(by: {$0.zPosition > $1.zPosition})
        
        guard let button = findButton(in: sorted), let tapAction = button.action else {
            topScreen.handleTap(at: point)
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
    
    func screens(in nodes: [SKNode]) -> [Screen] {
        var result = nodes.flatMap({ $0 as? Screen })
        return result.sorted(by: {$0.zPosition > $1.zPosition})
    }
    
    func findButton(in nodes: [AnyObject]) -> Button? {
        let usedNodes: [AnyObject]
        if #available(iOS 9, *) {
            usedNodes = nodes
        } else {
            usedNodes = nodes.reversed()
        }
        
        for node in usedNodes {
            if let button = node as? Button {
                return button
            }
        }
        
        return nil
    }
    
    open func dismiss(_ screen: Screen) {
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
