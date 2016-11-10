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
import GameKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, InterstitialPresenter {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    private var scene: TenPairGame!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        Fabric.with([Crashlytics.self])
        
        window.minSize = NSMakeSize(400, 600)
        
        if !ReleaseBuild {
            Log.add(output: ConsoleOutput())
            Log.add(output: FileOutput())
            Log.logLevel = .debug
            
            Logging.set(logger: GameKitLogger())
        }
        
        Log.debug("App launch")
        
        let gameScene = TenPairGame(size: skView.bounds.size)
        if let save = UserDefaults.standard.object(forKey: TenPairSaveDataKey) as? [Int] {
            gameScene.startField = save
        }
        gameScene.scaleMode = SKSceneScaleMode.resizeFill
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        if !ReleaseBuild {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        skView.presentScene(scene)
        
        gameScene.startGame()
        
        gameScene.playScreen.interstitial = self
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillHide(_ notification: Notification) {
        Log.debug("")
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        Log.debug("")
        saveField()
    }

    func applicationWillTerminate(_ notification: Notification) {
        Log.debug("")
        saveField()
    }
    
    private func saveField() {
        let numbers = scene!.playScreen.playFieldNumbers()
        let defaults = UserDefaults.standard
        defaults.set(numbers, forKey: TenPairSaveDataKey)
        defaults.synchronize()
    }
}

private class GameKitLogger: GameKit.Logger {
    fileprivate func log<T>(_ object: T, file: String, function: String, line: Int) {
        let message = "L - \(object)"
        Log.debug(message, file: file, function: function, line: line)
    }
}

