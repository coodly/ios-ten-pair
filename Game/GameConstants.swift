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

enum Platform {
    case phone
    case pad
    case mac
}

let ReleaseBuild = true

struct AppConfig {
    let stats: Bool
    let ads: Bool
    let logs: Bool
    
    private static let development = AppConfig(stats: true, ads: true, logs: true)
    private static let production = AppConfig(stats: false, ads: true, logs: false)
    
    static let current: AppConfig = AppConfig.development
}
