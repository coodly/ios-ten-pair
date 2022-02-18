// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {

  public enum Coodly {
    public enum Feedback {
      public enum Controller {
        /// Conversations
        public static let title = L10n.tr("Localizable", "coodly.feedback.controller.title")
      }
      public enum Header {
        /// Please read this before posting
        public static let message = L10n.tr("Localizable", "coodly.feedback.header.message")
      }
      public enum Message {
        public enum Compose {
          public enum Controller {
            /// Write message
            public static let title = L10n.tr("Localizable", "coodly.feedback.message.compose.controller.title")
            public enum Send {
              /// Send
              public static let button = L10n.tr("Localizable", "coodly.feedback.message.compose.controller.send.button")
            }
          }
        }
      }
      public enum Response {
        /// Hello
        /// 
        /// I'm Jaanus Siim, an independent developer based in Estonia.
        /// 
        /// Every suggestion and feedback is welcome. I promise to read them all. But I may not be able to respond to all messages.
        /// 
        /// Thanks for understanding.
        public static let notice = L10n.tr("Localizable", "coodly.feedback.response.notice")
      }
      public enum Sign {
        public enum In {
          /// Please sign in to iCloud to send a message.
          public static let message = L10n.tr("Localizable", "coodly.feedback.sign.in.message")
        }
      }
    }
  }

  public enum Feedback {
    public enum Greeting {
      /// I'm Jaanus Siim, independent developer based in Estonia. Every suggestion and feedback is welcome. I promise to read them all.
      public static let message = L10n.tr("Localizable", "feedback.greeting.message")
      /// Hi there!
      public static let title = L10n.tr("Localizable", "feedback.greeting.title")
    }
    public enum Login {
      /// Please sign in to iCloud to send a message
      public static let notice = L10n.tr("Localizable", "feedback.login.notice")
    }
  }

  public enum Menu {
    public enum Option {
      /// Personalized ads
      public static let gdpr = L10n.tr("Localizable", "menu.option.gdpr")
      /// Rate on AppStore
      public static let rate = L10n.tr("Localizable", "menu.option.rate")
      /// Restart game
      public static let restart = L10n.tr("Localizable", "menu.option.restart")
      /// Resume game
      public static let resume = L10n.tr("Localizable", "menu.option.resume")
      public enum Message {
        /// ● Response from developer
        public static let from = L10n.tr("Localizable", "menu.option.message.from")
      }
      public enum Rate {
        /// Rate app
        public static let app = L10n.tr("Localizable", "menu.option.rate.app")
      }
      public enum Remove {
        public enum Ads {
          /// Remove ads: 
          public static let base = L10n.tr("Localizable", "menu.option.remove.ads.base")
        }
      }
      public enum Restore {
        /// Restore purchase
        public static let purchase = L10n.tr("Localizable", "menu.option.restore.purchase")
      }
      public enum Send {
        /// Message to developer
        public static let message = L10n.tr("Localizable", "menu.option.send.message")
      }
      public enum Theme {
        /// Theme: %@
        public static func base(_ p1: Any) -> String {
          return L10n.tr("Localizable", "menu.option.theme.base", String(describing: p1))
        }
      }
    }
  }

  public enum Moviez {
    public enum Sale {
      /// App from Coodly. Helping to discover good movies on iTunes.
      public static let body = L10n.tr("Localizable", "moviez.sale.body")
      /// Find movies to watch
      public static let title = L10n.tr("Localizable", "moviez.sale.title")
    }
  }

  public enum Restart {
    public enum Screen {
      /// Back
      public static let back = L10n.tr("Localizable", "restart.screen.back")
      public enum Option {
        /// Regular board
        public static let regular = L10n.tr("Localizable", "restart.screen.option.regular")
        public enum X {
          /// Random ~%@ lines
          public static func lines(_ p1: Any) -> String {
            return L10n.tr("Localizable", "restart.screen.option.x.lines", String(describing: p1))
          }
        }
      }
    }
  }

  public enum Theme {
    public enum Name {
      /// Classic
      public static let classic = L10n.tr("Localizable", "theme.name.classic")
      /// Dark
      public static let dark = L10n.tr("Localizable", "theme.name.dark")
      /// Honeycomb
      public static let honeycomb = L10n.tr("Localizable", "theme.name.honeycomb")
      /// Pink
      public static let pink = L10n.tr("Localizable", "theme.name.pink")
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
