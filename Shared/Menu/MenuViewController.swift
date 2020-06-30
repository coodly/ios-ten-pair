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

internal class MenuViewController: MenuOptionsViewController, StoryboardLoaded, GDPRCheckConsumer {
    var gdprCheck: GDPRCheck?
    
    internal var gameWon = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshMenuOptions()
    }
    
    private func refreshMenuOptions() {
        options.removeAll()
        if !gameWon {
            options.append(.resume)
        }
        options.append(.restart(-1))
        options.append(.theme(AppTheme.shared.active))
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 13, *) {
            options.append(.feedback(FeedbackService.hasMessage()))
        }
        #endif
        if gdprCheck?.showGDPRConsentMenuItem ?? false {
            options.append(.personalizedAds)
        }
    }
    
    override func tapped(on option: MenuOption) {
        switch option {
        case .restart(_):
            let restart: RestartViewController = Storyboards.loadFromStoryboard()
            restart.delegate = delegate
            navigationController?.pushViewController(restart, animated: false)
        case .theme(_):
            _ = AppTheme.shared.switchToNext()
            refreshMenuOptions()
            tableView.reloadData()
        case .personalizedAds:
            gdprCheck?.present()
        case .feedback(_):
            if #available(iOS 13, *) {
                FeedbackService.present()
            }
        default:
            super.tapped(on: option)
        }
    }
}
