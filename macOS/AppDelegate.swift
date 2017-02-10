//
//  AppDelegate.swift
//  TenPair
//
//  Created by Jaanus Siim on 06/02/2017.
//  Copyright © 2017 Coodly LLC. All rights reserved.
//

import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    private var scene: TenPair!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true, "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints": true])
        
        Log.enable()
        
        window.minSize = NSMakeSize(400, 600)
        
        let gameScene = TenPair(size: skView.bounds.size)
        gameScene.scaleMode = .resizeFill
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.presentScene(scene)
        gameScene.start()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

