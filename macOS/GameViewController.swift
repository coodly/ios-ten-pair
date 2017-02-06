//
//  GameViewController.swift
//  macOS
//
//  Created by Jaanus Siim on 06/02/2017.
//  Copyright © 2017 Coodly LLC. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let scene = TenPair(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        scene.start()
    }
}

