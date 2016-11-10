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

#if os(iOS)
import Foundation

public class ShakeWindow: UIWindow {
    public override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            presentMailController()
        }
        
        super.motionEnded(motion, with: event)
    }
    
    private func presentMailController() {
        let logsController = LogsViewController()
        let navigation = UINavigationController(rootViewController: logsController)
        rootViewController?.present(navigation, animated: true, completion: nil)
    }
}
#endif
