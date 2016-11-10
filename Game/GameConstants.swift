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

func onMainThread(_ closure: @escaping () -> ()) {
    onQueue(DispatchQueue.main, closure: closure)
}

func inBackground(_ closure: @escaping () -> ()) {
    onQueue(DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background), closure: closure)
}

private func onQueue(_ queue: DispatchQueue, closure: @escaping () -> ()) {
    queue.async(execute: closure)
}

enum Platform {
    case phone
    case pad
    case mac
}

let ReleaseBuild = true
