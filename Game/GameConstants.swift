/*
 * Copyright 2016 Coodly LLC
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

let NumberOfColumns = 9

func onMainThread(closure: () -> ()) {
    onQueue(dispatch_get_main_queue(), closure: closure)
}

func inBackground(closure: () -> ()) {
    onQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), closure: closure)
}

private func onQueue(queue: dispatch_queue_t, closure: () -> ()) {
    dispatch_async(queue, closure)
}

enum Platform {
    case Phone
    case Pad
    case Mac
}

let ReleaseBuild = false
