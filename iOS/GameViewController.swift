//
//  GameViewController.swift
//  TenPair
//
//  Created by Jaanus Siim on 06/02/2017.
//  Copyright © 2017 Coodly LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {
    private var game: TenPair?
    private var ads: AdsCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView

        let scene = TenPair(size: skView.bounds.size)
        if AppConfig.current.ads {
            ads = AdsCoordinator()
            scene.ads = ads
        }
        game = scene
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        scene.start()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let scroll = scrollView(in: view) else {
            return
        }
        
        guard let container = scroll.subviews.filter({ !($0 is UIImageView) }).first else {
            return
        }
        
        ads?.presentIn = container
    }
    
    private func scrollView(in checked: UIView) -> UIScrollView? {
        for sub in checked.subviews {
            if let scoll = sub as? UIScrollView {
                return scoll
            } else if let subscroll = scrollView(in: sub) {
                return subscroll
            }
        }
        
        return nil
    }
}
