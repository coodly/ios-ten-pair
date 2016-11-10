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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics()])

        if !ReleaseBuild {
            Log.add(output: ConsoleOutput())
            Log.add(output: FileOutput())
            Log.logLevel = .debug
            
            if wipeIAP() {
                Log.debug("Wipe IAP")
                removeFullVersion()
            }
            
            Logging.set(logger: LaughingLogger())
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let controller = application.keyWindow!.rootViewController! as! GameViewController
        controller.saveField()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

private extension AppDelegate {
    func wipeIAP() -> Bool {
        let env = ProcessInfo.processInfo.environment
        if let envValue = env["WIPE"], envValue == "1" {
            return true
        }
        
        return false
    }
}

private class LaughingLogger: LaughingAdventure.Logger {
    fileprivate func log<T>(_ object: T, file: String, function: String, line: Int) {
        let message = "L - \(object)"
        Log.debug(message, file: file, function: function, line: line)
    }
}
