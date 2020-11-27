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

internal class PurchaseViewModel: ObservableObject {
    
}

internal struct PurchaseView: View {
    @ObservedObject var viewModel: PurchaseViewModel
    
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
