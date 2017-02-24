/*
 * Copyright 2017 Coodly LLC
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

import Cocoa
import SpriteKit
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    private var scene: TenPair!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        //, "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints": true
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        Fabric.with([Crashlytics.self])

        Log.enable()
        
        window.minSize = NSMakeSize(400, 600)
        
        let gameScene = TenPair(size: skView.bounds.size)
        gameScene.scaleMode = .resizeFill
        scene = gameScene
        skView.allowsTransparency = false
        skView.shouldCullNonVisibleNodes = false
        skView.showsFPS = AppConfig.current.logs
        skView.showsNodeCount = AppConfig.current.logs
        skView.presentScene(scene)
        gameScene.start()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        NotificationCenter.default.post(name: .saveField, object: nil)
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        NotificationCenter.default.post(name: .saveField, object: nil)
    }
}

