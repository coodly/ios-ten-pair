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

public protocol SelectionSource {
    var tableView: UITableView! { get set }
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func objectAtIndexPath(_ indexPath: IndexPath) -> AnyObject
    func indexPathForObject(_ object: AnyObject) -> IndexPath?
}
