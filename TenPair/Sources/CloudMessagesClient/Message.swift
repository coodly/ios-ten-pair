import Foundation

public struct Message: Equatable, Codable, Identifiable, Comparable {
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
