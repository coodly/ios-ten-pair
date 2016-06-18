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

import UIKit
import Fabric
import Crashlytics
import SWLogger
import LaughingAdventure

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FullVersionHandler {
    var window: UIWindow?
    private let laughingDelegate = LaughingDelegate()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])

        Log.addOutput(ConsoleOutput())
        Log.addOutput(FileOutput())
        Log.logLevel = Log.Level.DEBUG
        
        if wipeIAP() {
            Log.debug("Wipe IAP")
            removeFullVersion()
        }
        
        Logging.sharedInstance.delegate = laughingDelegate
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        let controller = application.keyWindow!.rootViewController! as! GameViewController
        controller.saveField()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

private extension AppDelegate {
    func wipeIAP() -> Bool {
        let env = NSProcessInfo.processInfo().environment
        if let envValue = env["WIPE"] where envValue == "1" {
            return true
        }
        
        return false
    }
}

private class LaughingDelegate: LaughingAdventure.LoggingDelegate {
    private func log<T>(object: T, file: String, function: String, line: Int) {
        let message = "L - \(object)"
        Log.debug(message, file: file, function: function, line: line)
    }
}
