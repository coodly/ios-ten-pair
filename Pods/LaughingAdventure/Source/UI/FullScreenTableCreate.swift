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

public protocol FullScreenTableCreate: UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView! { get set }
    func checkTableView(_ style: UITableViewStyle)
}

public extension FullScreenTableCreate where Self: UIViewController {
    func checkTableView(_ style: UITableViewStyle = .plain) {
        if tableView != nil {
            return
        }
        
        //not loaded from xib
        tableView = UITableView(frame: view.bounds, style: style)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let views: [String: AnyObject] = ["table": tableView]
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: [], metrics: nil, views: views)
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|", options: [], metrics: nil, views: views)
        
        view.addConstraints(vertical + horizontal)
    }
}
