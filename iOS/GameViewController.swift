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

class GameViewController: UIViewController, QuickAlertPresenter {
    private var game: TenPair?
    private var ads: AdsCoordinator?
    @IBOutlet private var gameContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = SKView(frame: gameContainerView.bounds)
        gameContainerView.add(fullSized: skView)        

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
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // sanity check
        if AdMobAdUnitID != ReleaseNativeUnitID {
            presentAlert("Ad unit", message: "Demo unit used")
        }
        
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
