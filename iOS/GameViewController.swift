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
import LaughingAdventure

class GameViewController: AdLoadingViewController, QuickAlertPresenter {
    private var game: TenPair?
    @IBOutlet private var gameContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = SKView(frame: gameContainerView.bounds)
        gameContainerView.add(fullSized: skView)        

        let scene = TenPair(size: skView.bounds.size)
        game = scene
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        skView.showsFPS = AppConfig.current.showDebugInfo
        skView.showsNodeCount = AppConfig.current.showDebugInfo
        
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
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // sanity check
        if AppConfig.current.adUnits.banner != AdUnits.live.banner {
            presentAlert("Ad unit", message: "Demo unit used")
        }
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
