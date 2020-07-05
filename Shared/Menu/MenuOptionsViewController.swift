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

internal enum MenuOption {
    case resume
    case restart(Int)
    case theme(ThemeDefinition)
    case feedback(Bool)
    case personalizedAds
    case back
    case logs
    
    var title: String {
        switch self {

        case .resume:
            return NSLocalizedString("menu.option.resume", comment: "")
        case .restart(let lines):
            switch lines {
            case -1:
                return NSLocalizedString("menu.option.restart", comment: "")
            case 0:
                return NSLocalizedString("restart.screen.option.regular", comment: "")
            default:
                return String(format: NSLocalizedString("restart.screen.option.x.lines", comment: ""), NSNumber(value: lines))
            }
        case .theme(let active):
            return String(format: NSLocalizedString("menu.option.theme.base", comment: ""), active.localizedName)
        case .feedback(let hasMessage):
            return hasMessage ? NSLocalizedString("menu.option.message.from", comment: "") : NSLocalizedString("menu.option.send.message", comment: "")
        case .personalizedAds:
            return NSLocalizedString("menu.option.gdpr", comment: "")
        case .back:
            return NSLocalizedString("restart.screen.back", comment: "")
        case .logs:
            return "Logs"
        }
    }
}

internal protocol MenuDelegate: class {
    func tapped(option: MenuOption)
}

internal class MenuOptionsViewController: UIViewController {
    private(set) lazy var tableView = ContentSizeBasedTableView()
    private lazy var dimView = OverlayBackgroundView()
    
    internal var options = [MenuOption]()
    
    internal weak var delegate: MenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.insertSubview(dimView, at: 0)
        dimView.pinToSuperviewEdges()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        dimView.addGestureRecognizer(tap)
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        tableView.registerCell(forType: MenuCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc fileprivate func dismissMenu() {
        delegate?.tapped(option: .resume)
    }
    
    internal func tapped(on option: MenuOption) {
        delegate?.tapped(option: option)
    }
}

extension MenuOptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuCell = tableView.dequeueReusableCell()
        cell.title.text = options[indexPath.row].title
        return cell
    }
}

extension MenuOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapped(on: options[indexPath.row])
    }
}
