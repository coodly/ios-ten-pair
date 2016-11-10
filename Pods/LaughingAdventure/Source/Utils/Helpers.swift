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

import Foundation

public func runAfter(_ seconds: TimeInterval, onQueue queue: DispatchQueue = DispatchQueue.main, closure: @escaping () -> ()) {
    let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    queue.asyncAfter(deadline: delayTime, execute: closure)
}

public func onMainThread(_ closure: @escaping () -> ()) {
    DispatchQueue.main.async(execute: closure)
}

public func timeMeasured(_ desc: String = "", closure: () -> ()) {
    let start = CACurrentMediaTime()
    closure()
    Logging.log(String(format: "%@ - time: %f", desc, CACurrentMediaTime() - start))
}
