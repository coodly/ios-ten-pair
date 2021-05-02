/*
* Copyright 2020 Coodly LLC
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

public protocol StoryboardLoaded: AnyObject {
    static var storyboardName: String { get }
}

extension StoryboardLoaded where Self: UIViewController {
    public static var storyboardName: String {
        String(describing: self).replacingOccurrences(of: "ViewController", with: "")
    }
}
