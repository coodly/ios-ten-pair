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

import Combine
import FeedbackClient
import Localization
import Purchase
import RemoveAds
import SwiftUI
import Themes
import UIComponents

internal protocol MenuViewModelDelegate: AnyObject {
    func resume()
    func restart(lines: Int)
    func rateApp()
    func showFeedback()
}

fileprivate enum MenuMode: String {
    case main
    case restart
}

internal class MenuViewModel: ObservableObject {
    fileprivate let randomLines = [20, 50, 100, 250, 500, 1_000]
    
    fileprivate lazy var purchaseViewModel = PurchaseViewModel(
        onRateApp: { [weak self] in self?.delegate?.rateApp() }
    )
    
    @Published fileprivate var mode = MenuMode.main
    @Published fileprivate var activeTheme = AppTheme.shared.active
    @Published fileprivate var showPersonalizedAdsRow = false
    @Published fileprivate var haveMessageFromDeveloper = false

    fileprivate let showResume: Bool
    private var adsStatusSubscription: AnyCancellable?
    private var unreadSubscription: AnyCancellable?

    private weak var delegate: MenuViewModelDelegate?
    internal init(delegate: MenuViewModelDelegate, gameWon: Bool) {
        self.delegate = delegate
        showResume = !gameWon
        
        //unreadSubscription = FeedbackService.unreadStatus.receive(on: DispatchQueue.main)
        //    .sink() {
        //        [weak self]
        //
        //        haveUnread in
        //
        //        self?.haveMessageFromDeveloper = haveUnread
        //    }
    }
    
    fileprivate func showRestart() {
        mode = .restart
    }
    
    fileprivate func showMain() {
        mode = .main
    }
    
    fileprivate func resume() {
        delegate?.resume()
    }
    
    fileprivate func switchTheme() {
        activeTheme = AppTheme.shared.switchToNext()
    }
    
    fileprivate func restart(lines: Int) {
        delegate?.restart(lines: lines)
    }
        
    fileprivate func showFeedback() {
        delegate?.showFeedback()
    }
}

internal struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        ZStack {
            MenuBackground()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: viewModel.resume)
            VStack(spacing: 4) {
                if viewModel.mode == .main {
                    MainMenuView(viewModel: viewModel)
                } else {
                    RestartSection(viewModel: viewModel)
                }
            }
            .frame(width: 280, alignment: .center)
            .buttonStyle(MenuButtonStyle())
        }
    }
}

private struct MainMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            if viewModel.showResume {
                Button(action: viewModel.resume) {
                    Text(L10n.Menu.Option.resume)
                }
            }
            Button(action: viewModel.showRestart) {
                Text(L10n.Menu.Option.restart)
            }
            Button(action: viewModel.switchTheme) {
                Text(L10n.Menu.Option.Theme.base(viewModel.activeTheme.name))
            }
            if RemoveAds.active.platformHasAds {
                PurchaseView(viewModel: viewModel.purchaseViewModel)
            }
            if #available(iOS 14, *), viewModel.haveMessageFromDeveloper, FeedbackClient.active.platformHasFeedback {
                Button(action: viewModel.showFeedback) {
                    Text(L10n.Menu.Option.Message.from)
                }
            } else if #available(iOS 14, *), FeedbackClient.active.platformHasFeedback {
                Button(action: viewModel.showFeedback) {
                    Text(L10n.Menu.Option.Send.message)
                }
            }
        }
    }
}

private struct RestartSection: View {
    let viewModel: MenuViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: { viewModel.restart(lines: 0) }) {
                Text(L10n.Restart.Screen.Option.regular)
            }
            ForEach(viewModel.randomLines, id: \.self) {
                number in
                
                Button(action: { viewModel.restart(lines: number) } ) {
                    Text(L10n.Restart.Screen.Option.X.lines(number))
                }
            }
            Button(action: viewModel.showMain) {
                Text(L10n.Restart.Screen.back)
            }
        }
    }
}
