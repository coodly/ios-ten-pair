import CloudMessagesClient
import Foundation
import Logging

internal struct MessagesStore: Codable {
    private static let saveURL: URL? = {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return nil
        }
        
        try? FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        return documents.appendingPathComponent("feedback-messages.json")
    }()
    internal var cornversationRecordName: String?
    internal var messages: [Message] = []
    
    internal mutating func update(messages: [Message]) -> Bool {
        var receivedNew = false
        for message in messages {
            if self.messages.contains(where: { $0.recordName == message.recordName }) {
                continue
            } else {
                self.messages.append(message)
                receivedNew = receivedNew || !message.sentFromApp
            }
        }
        self.messages.sort()
        
        return receivedNew
    }
    
    static func load() -> MessagesStore {
        do {
            guard let path = MessagesStore.saveURL else {
                return MessagesStore()
            }
            
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(MessagesStore.self, from: data)
        } catch {
            Log.feedback.error(error)
            return MessagesStore()
        }
    }
    
    internal func save() {
        do {
            guard let path = MessagesStore.saveURL else {
                return
            }
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(self)
            try data.write(to: path)
        } catch {
            Log.feedback.error(error)
        }
    }
}
