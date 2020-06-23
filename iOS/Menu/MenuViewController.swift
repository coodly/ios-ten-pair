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

private enum MenuOption {
    case resume
    case restart
    case theme
    case feedback
    case personalizedAds
    
    var title: String {
        switch self {

        case .resume:
            return NSLocalizedString("menu.option.resume", comment: "")
        case .restart:
            return NSLocalizedString("menu.option.restart", comment: "")
        case .theme:
            return "Theme"
        case .feedback:
            return NSLocalizedString("menu.option.send.message", comment: "")
        case .personalizedAds:
            return NSLocalizedString("menu.option.gdpr", comment: "")
        }
    }
}

internal class MenuViewController: UIViewController, StoryboardLoaded {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var dimView: UIView!
    
    private var options = [MenuOption]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dimView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        dimView.addGestureRecognizer(tap)
        
        tableView.registerCell(forType: MenuCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc fileprivate func dismissMenu() {
        dismiss(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        options.append(.resume)
        options.append(.restart)
        options.append(.theme)
        options.append(.feedback)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuCell = tableView.dequeueReusableCell()
        cell.title.text = options[indexPath.row].title.uppercased()
        return cell
    }
}
