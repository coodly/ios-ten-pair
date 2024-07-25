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

import Foundation
import Localization
import UIComponents
import UIKit

extension Notification.Name {
  public static let themeChanged = Notification.Name("com.coodly.ten.pair.theme.changed")
}

private let ThemeSettingKey = "ThemeSettingKey"

public class AppTheme {
  private static let classicMain = UIColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1)
  private static let pinkMain = UIColor(red: 1, green: 105.0 / 255.0, blue: 180.0 / 255.0, alpha: 1)
  internal static let classic = ThemeDefinition(
    name: "classic",
    main: classicMain,
    selected: UIColor(red: 0, green: 0.400, blue: 1.000, alpha: 1),
    success: UIColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1),
    empty: UIColor(white: 0.900, alpha: 1.000),
    background: UIColor.white,
    statusBar: .default,
    navigationTint: classicMain,
    text: .white,
    tileBackground: .white,
    buttonsForeground: .white,
    defaultTileBackground: classicMain,
    barTintColor: .white
  )
    
  internal static let pink = ThemeDefinition(
    name: "pink",
    main: pinkMain,
    selected: UIColor(red: 60.0 / 255.0, green: 145.0 / 255.0, blue: 230.0 / 255.0, alpha: 1),
    success: UIColor(red: 27.0 / 255.0, green: 153.0 / 255.0, blue: 130.0 / 255.0, alpha: 1),
    empty: UIColor(white: 0.900, alpha: 1.000),
    background: UIColor.white,
    statusBar: .default,
    navigationTint: pinkMain,
    text: .white,
    tileBackground: .white,
    buttonsForeground: .white,
    defaultTileBackground: pinkMain,
    barTintColor: .white
  )
    
  public static let darkMainColor = UIColor.color(hexString: "#243458")
  internal static let dark = ThemeDefinition(
    name: "dark",
    main: darkMainColor,
    selected: UIColor(red: 60.0 / 255.0, green: 145.0 / 255.0, blue: 230.0 / 255.0, alpha: 1),
    success: UIColor(red: 0.239, green: 0.792, blue: 0.416, alpha: 1),
    empty: UIColor(white: 0.500, alpha: 1.000),
    background: UIColor.color(hexString: "#121212"),
    statusBar: .lightContent,
    navigationTint: .white,
    text: .white,
    tileBackground: UIColor.color(hexString: "#D4D4D4"),
    buttonsForeground: .white,
    defaultTileBackground: darkMainColor,
    barTintColor: UIColor.color(hexString: "#121212")
  )

  internal static let honeycombMain = UIColor(red: 246.0 / 255.0, green: 205.0 / 255.0, blue: 69.0 / 255.0, alpha: 1)
  private static let honeycombText = UIColor(red: 76.0 / 255.0, green: 55.0 / 255.0, blue: 36.0 / 255.0, alpha: 1)
  private static let honeycombGray = UIColor(red: 221.0 / 255.0, green: 220.0 / 255.0, blue: 221.0 / 255.0, alpha: 1)
  private static let honeycombLight = UIColor(red: 251.0 / 255.0, green: 229.0 / 255.0, blue: 214.0 / 255.0, alpha: 1)
  private static let honeycombEmpty = UIColor(red: 239.0 / 255.0, green: 211.0 / 255.0, blue: 193.0 / 255.0, alpha: 1)
  internal static let honeycomb = ThemeDefinition(
    name: "honeycomb",
    main: honeycombMain,
    selected: UIColor(red: 240.0 / 255.0, green: 156.0 / 255.0, blue: 70.0 / 255.0, alpha: 1),
    success: UIColor(red: 27.0 / 255.0, green: 153.0 / 255.0, blue: 130.0 / 255.0, alpha: 1),
    empty: honeycombEmpty,
    background: honeycombLight,
    statusBar: .default,
    navigationTint: honeycombText,
    text: honeycombText,
    tileBackground: honeycombGray,
    buttonsForeground: honeycombText,
    defaultTileBackground: honeycombMain,
    barTintColor: honeycombMain
  )

  private static let all: [ThemeDefinition] = [classic, pink, dark, honeycomb]
    
  public static let shared = AppTheme()
    
  public var active: ThemeDefinition {
    activeTheme
  }
    
  private init() {}
    
  public func load() {
    apply(theme: activeTheme)
  }
    
  private var activeTheme: ThemeDefinition {
    let name = UserDefaults.standard.string(forKey: ThemeSettingKey) ?? "classic"
    if let existing = AppTheme.all.filter({ $0.name == name }).first {
      return existing
    }
        
    return AppTheme.classic
  }
    
  private func apply(theme: ThemeDefinition) {
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.navigationTint]
    UINavigationBar.appearance().tintColor = theme.navigationTint
    UINavigationBar.appearance().barTintColor = theme.barTintColor
    TileDefaultBackground.appearance().backgroundColor = theme.defaultTileBackground
    TileNoNumberBackground.appearance().backgroundColor = theme.empty
    TileSelectedBackground.appearance().backgroundColor = theme.selected
    TileSuccessBackground.appearance().backgroundColor = theme.success
    TileFailureBackground.appearance().backgroundColor = theme.failure
    MenuCellBackground.appearance().backgroundColor = theme.main
    BackgroundView.appearance().backgroundColor = theme.background
    OverlayBackgroundView.appearance().backgroundColor = theme.background.withAlphaComponent(0.9)
    ButtonTrayBackgroundView.appearance().backgroundColor = theme.main
    ButtonTrayView.appearance().backgroundColor = .white
    UILabel.appearance(whenContainedInInstancesOf: [NumberCell.self]).textColor = theme.text
    UIButton.appearance(whenContainedInInstancesOf: [ButtonTrayView.self]).tintColor = theme.text
    TileBackgroundView.appearance().backgroundColor = theme.tileBackground
    //StatusLabel.appearance().textColor = theme.navigationTint
    SpinnerView.appearance().tintColor = theme.navigationTint
    UIButton.appearance(whenContainedInInstancesOf: [ButtonTrayView.self]).tintColor = theme.buttonsForeground
  }
    
  public func switchToNext() -> ThemeDefinition {
    let current = activeTheme
    guard let index = AppTheme.all.firstIndex(of: current) else {
      return active
    }
        
    let next = index.advanced(by: 1)
    let returned: ThemeDefinition
    if AppTheme.all.endIndex <= next {
      returned = AppTheme.all.first!
    } else {
      returned = AppTheme.all[next]
    }
        
    apply(theme: returned)
    UserDefaults.standard.set(returned.name, forKey: ThemeSettingKey)
    for window in UIApplication.shared.windows {
      for sub in window.subviews {
        sub.removeFromSuperview()
        window.addSubview(sub)
      }
    }
    NotificationCenter.default.post(name: .themeChanged, object: nil)
    return returned
  }
}

public struct ThemeDefinition: Equatable {
  public let name: String
  public let main: UIColor
  public let selected: UIColor
  public let success: UIColor
  public let failure = UIColor(red: 1.000, green: 0.173, blue: 0.333, alpha: 1)
  public let empty: UIColor
  public let background: UIColor
  public let statusBar: UIStatusBarStyle
  public let navigationTint: UIColor
  public let text: UIColor
  public let tileBackground: UIColor
  public let buttonsForeground: UIColor
  public let defaultTileBackground: UIColor
  public let barTintColor: UIColor
    
  public var localizedName: String {
    switch name {
    case "classic":
      return L10n.Theme.Name.classic
    case "dark":
      return L10n.Theme.Name.dark
    case "honeycomb":
      return L10n.Theme.Name.honeycomb
    case "pink":
      return L10n.Theme.Name.pink
    default:
      return "unnamed-\(name)"
    }
  }
}
