// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Coodly {
    internal enum Feedback {
      internal enum Controller {
        /// Conversations
        internal static let title = L10n.tr("Localizable", "coodly.feedback.controller.title")
      }
      internal enum Header {
        /// Please read this before posting
        internal static let message = L10n.tr("Localizable", "coodly.feedback.header.message")
      }
      internal enum Message {
        internal enum Compose {
          internal enum Controller {
            /// Write message
            internal static let title = L10n.tr("Localizable", "coodly.feedback.message.compose.controller.title")
            internal enum Send {
              /// Send
              internal static let button = L10n.tr("Localizable", "coodly.feedback.message.compose.controller.send.button")
            }
          }
        }
      }
      internal enum Response {
        /// Hello\n\nI'm Jaanus Siim, an independent developer based in Estonia.\n\nEvery suggestion and feedback is welcome. I promise to read them all. But I may not be able to respond to all messages.\n\nThanks for understanding.
        internal static let notice = L10n.tr("Localizable", "coodly.feedback.response.notice")
      }
      internal enum Sign {
        internal enum In {
          /// Please sign in to iCloud to send a message.
          internal static let message = L10n.tr("Localizable", "coodly.feedback.sign.in.message")
        }
      }
    }
  }

  internal enum Feedback {
    internal enum Greeting {
      /// I'm Jaanus Siim, independent developer based in Estonia. Every suggestion and feedback is welcome. I promise to read them all.
      internal static let message = L10n.tr("Localizable", "feedback.greeting.message")
      /// Hi there!
      internal static let title = L10n.tr("Localizable", "feedback.greeting.title")
    }
    internal enum Login {
      /// Please sign in to iCloud to send a message
      internal static let notice = L10n.tr("Localizable", "feedback.login.notice")
    }
  }

  internal enum Menu {
    internal enum Option {
      /// Personalized ads
      internal static let gdpr = L10n.tr("Localizable", "menu.option.gdpr")
      /// Rate on AppStore
      internal static let rate = L10n.tr("Localizable", "menu.option.rate")
      /// Restart game
      internal static let restart = L10n.tr("Localizable", "menu.option.restart")
      /// Resume game
      internal static let resume = L10n.tr("Localizable", "menu.option.resume")
      internal enum Message {
        /// ● Response from developer
        internal static let from = L10n.tr("Localizable", "menu.option.message.from")
      }
      internal enum Rate {
        /// Rate app
        internal static let app = L10n.tr("Localizable", "menu.option.rate.app")
      }
      internal enum Remove {
        internal enum Ads {
          /// Remove ads: 
          internal static let base = L10n.tr("Localizable", "menu.option.remove.ads.base")
        }
      }
      internal enum Restore {
        /// Restore purchase
        internal static let purchase = L10n.tr("Localizable", "menu.option.restore.purchase")
      }
      internal enum Send {
        /// Message to developer
        internal static let message = L10n.tr("Localizable", "menu.option.send.message")
      }
      internal enum Theme {
        /// Theme: %@
        internal static func base(_ p1: Any) -> String {
          return L10n.tr("Localizable", "menu.option.theme.base", String(describing: p1))
        }
      }
    }
  }

  internal enum Moviez {
    internal enum Sale {
      /// App from Coodly. Helping to discover good movies on iTunes.
      internal static let body = L10n.tr("Localizable", "moviez.sale.body")
      /// Find movies to watch
      internal static let title = L10n.tr("Localizable", "moviez.sale.title")
    }
  }

  internal enum Restart {
    internal enum Screen {
      /// Back
      internal static let back = L10n.tr("Localizable", "restart.screen.back")
      internal enum Option {
        /// Regular board
        internal static let regular = L10n.tr("Localizable", "restart.screen.option.regular")
        internal enum X {
          /// Random ~%@ lines
          internal static func lines(_ p1: Any) -> String {
            return L10n.tr("Localizable", "restart.screen.option.x.lines", String(describing: p1))
          }
        }
      }
    }
  }

  internal enum Theme {
    internal enum Name {
      /// Classic
      internal static let classic = L10n.tr("Localizable", "theme.name.classic")
      /// Dark
      internal static let dark = L10n.tr("Localizable", "theme.name.dark")
      /// Honeycomb
      internal static let honeycomb = L10n.tr("Localizable", "theme.name.honeycomb")
      /// Pink
      internal static let pink = L10n.tr("Localizable", "theme.name.pink")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
