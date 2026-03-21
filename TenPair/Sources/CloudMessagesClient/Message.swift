import Foundation
import Sharing

public struct Message: Equatable, Codable, Identifiable, Comparable, Sendable {
  public var id: String {
    recordName
  }
    
  public let recordName: String
  public let sentFromApp: Bool
  public let sentBy: String
  public let content: String
  public let postedAt: Date
    
  public init(recordName: String, sentFromApp: Bool, sentBy: String, content: String, postedAt: Date) {
    self.recordName = recordName
    self.sentFromApp = sentFromApp
    self.sentBy = sentBy
    self.content = content
    self.postedAt = postedAt
  }
    
  public static func < (lhs: Message, rhs: Message) -> Bool {
    lhs.postedAt < rhs.postedAt
  }
}

public extension SharedReaderKey where Self == AppStorageKey<Bool>.Default {
  static var hasUnreadMessages: Self {
    Self[.appStorage("com_coodly_ten_pair_has_unread"), default: false]
  }
}

public extension SharedReaderKey where Self == InMemoryKey<[Message]>.Default {
  static var messages: Self {
    Self[.inMemory("com.coodly.ten.pair.messages"), default: []]
  }
}
