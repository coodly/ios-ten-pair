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

import SwiftUI

internal class MenuViewModel: ObservableObject {
    fileprivate let randomLines = [20, 50, 100, 250]
}

internal struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                Text(L10n.Menu.Option.resume)
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.restart)
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.Theme.base("Cake"))
            }
            PurchaseSection()
            Button(action: {}) {
                Text(L10n.Menu.Option.Send.message)
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.Message.from)
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.gdpr)
            }
            Button(action: {}) {
                Text("Logs")
            }
            RestartSection(viewModel: viewModel)
        }
        .frame(width: 250, alignment: .center)
        .buttonStyle(MenuButtonStyle())
    }
}

private struct PurchaseSection: View {
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                Text(L10n.Menu.Option.Remove.Ads.base("€1.00"))
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.Restore.purchase)
            }
        }
    }
}

private struct RestartSection: View {
    let viewModel: MenuViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                Text(L10n.Restart.Screen.Option.regular)
            }
            ForEach(viewModel.randomLines, id: \.self) {
                number in
                
                Button(action: {}) {
                    Text(L10n.Restart.Screen.Option.X.lines(number))
                }
            }
            Button(action: {}) {
                Text(L10n.Restart.Screen.back)
            }
        }
    }
}

internal struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font(UIFont(name: "Copperplate Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)))
            .foregroundColor(.white)
            .frame(minWidth: 44, maxWidth: .infinity, minHeight: 44, alignment: .center)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .background(Color.red)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
