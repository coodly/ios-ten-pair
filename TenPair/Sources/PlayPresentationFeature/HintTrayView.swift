/*
 * Copyright 2026 Coodly LLC
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

import ComposableArchitecture
import PlayFeature
import SwiftUI

struct HintTrayView: View {
  let store: StoreOf<ButtonTray>
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Image(systemName: "lightbulb.fill")
        .font(.headline.weight(.heavy))
        .frame(width: 44, height: 44)
    }
    .padding(.leading, 4)
    .modifier(HintTrayModifier(store: store))
    .padding(.bottom)
    .foregroundStyle(store.foregroundColor)
  }
}

struct HintTrayModifier: ViewModifier {
  let store: StoreOf<ButtonTray>
  let rectangle = UnevenRoundedRectangle(
    topLeadingRadius: 0,
    bottomLeadingRadius: 0,
    bottomTrailingRadius: 22,
    topTrailingRadius: 22,
    style: .continuous
  )
  
  func body(content: Content) -> some View {
    if #available(iOS 26.0, *) {
      content
        .glassEffect(.clear.tint(store.backgroundColor), in: rectangle)
    } else {
      content
        .foregroundStyle(store.foregroundColor)
        .background(
          content: {
              rectangle
              .foregroundStyle(store.backgroundColor)
          }
        )
        .overlay(
          rectangle
            .stroke(store.foregroundColor, lineWidth: 1)
        )
    }
  }
}
