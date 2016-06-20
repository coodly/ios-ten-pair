//
//  AppDelegate.swift
//  MacTenPair
//
//  Created by Jaanus Siim on 19/06/16.
//  Copyright (c) 2016 Coodly LLC. All rights reserved.
//


import Cocoa
import SpriteKit
import Fabric
import Crashlytics
import SWLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    private var scene: TenPairGame!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserDefaults.standardUserDefaults().registerDefaults(["NSApplicationCrashOnExceptions": true])
        Fabric.with([Crashlytics.self])
        
        Log.addOutput(ConsoleOutput())
        Log.addOutput(FileOutput())
        Log.logLevel = Log.Level.DEBUG
        
        Log.debug("App launch")
        
        let gameScene = TenPairGame(size: skView.bounds.size)
        if let save = NSUserDefaults.standardUserDefaults().objectForKey(TenPairSaveDataKey) as? [Int] {
            gameScene.startField = save
        }
        gameScene.scaleMode = SKSceneScaleMode.ResizeFill
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        if !ReleaseBuild {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        skView.presentScene(scene)
        
        gameScene.startGame()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
