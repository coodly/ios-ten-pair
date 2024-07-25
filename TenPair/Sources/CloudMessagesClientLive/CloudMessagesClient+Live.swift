import CloudKit
import CloudMessagesClient
import Combine
import Dependencies
import Logging
import UIKit

extension CloudMessagesClient: DependencyKey {
  public static var liveValue: CloudMessagesClient {
    if #available(iOS 15.0, *) {
      .live
    } else {
      .noFeedback
    }
  }
}

@available(iOS 15.0, *)
extension CloudMessagesClient {
  public static var live: CloudMessagesClient {
    let container = CKContainer(identifier: "iCloud.com.coodly.feedback")
    let unreadPublisher = CurrentValueSubject<Bool, Never>(false)
    let messagesPublisher = CurrentValueSubject<[Message], Never>([])
        
    messagesPublisher.send(MessagesStore.load().messages)
        
    @Sendable
    func pullConversations(user: CKRecord.ID) async throws -> [CKRecord] {
      let userPredicate = NSPredicate(format: "creatorUserRecordID = %@", user)
      let appPredicate = NSPredicate(format: "appIdentifier = %@", Bundle.main.bundleIdentifier!)
      let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, appPredicate])
      let query = CKQuery(recordType: "Conversation", predicate: predicate)
      let (results, _) = try await container.publicCloudDatabase.records(matching: query)
      var conversations = [CKRecord]()
      for (_, result) in results {
        switch result {
        case .success(let record):
          conversations.append(record)
        case .failure(let error):
          Log.feedback.error(error)
        }
      }
      Log.feedback.debug("Loaded \(conversations.count) conversations")
      return conversations
    }
        
    @Sendable
    func pullThreadMessages(in conversation: CKRecord) async throws -> [CKRecord] {
      Log.cloud.debug("Pull messages in \(conversation.recordID)")
      var loaded = [CKRecord]()
            
      func append(results: [(CKRecord.ID, Result<CKRecord, any Error>)]) {
        for (_, result) in results {
          switch result {
          case .success(let record):
            loaded.append(record)
          case .failure(let error):
            Log.feedback.error(error)
          }
        }
      }
            
      let limit: Int = CKQueryOperation.maximumResults
            
      let predicate = NSPredicate(format: "conversation = %@", conversation.recordID)
      let query = CKQuery(recordType: "Message", predicate: predicate)
      let (results, cursor) = try await container.publicCloudDatabase.records(matching: query, resultsLimit: limit)
      append(results: results)
            
      var continuation = cursor
      while continuation != nil {
        Log.feedback.debug("Continue with cursor")
        let (results, cursor) = try await container.publicCloudDatabase.records(continuingMatchFrom: continuation!, resultsLimit: limit)
        append(results: results)
        continuation = cursor
      }
            
      return loaded
    }
        
    @Sendable
    func pullMessages(in conversations: [CKRecord]) async throws -> [CKRecord] {
      var messages = [CKRecord]()
      for conversation in conversations {
        let loaded = try await pullThreadMessages(in: conversation)
        messages.append(contentsOf: loaded)
      }
      Log.feedback.debug("Loaded \(messages.count) messages")
      return messages
    }
        
    func write(message: String) -> AnyPublisher<Void, Never> {
      Future<Void, Never>() {
        fulfill in
             
        Task {
          var store = MessagesStore.load()
          let savedMessage = CKRecord(recordType: "Message")
          savedMessage["body"] = message
          savedMessage["platform"] = await UIDevice.current.platform()
          savedMessage["postedAt"] = Date.now
                    
          var savedRecords = [CKRecord]()
                    
          if let name = store.cornversationRecordName {
            Log.feedback.debug("Use conversation reference")
            savedMessage["conversation"] = CKRecord.Reference(
              recordID: CKRecord.ID(recordName: name),
              action: .none
            )
          } else {
            Log.feedback.debug("Create conversation")
            let savedConversation = CKRecord(recordType: "Conversation", recordID: CKRecord.ID(recordName: UUID().uuidString))
            savedConversation["appIdentifier"] = Bundle.main.bundleIdentifier!
            savedConversation["lastMessageTime"] = Date.now
            savedConversation["snippet"] = ""
            savedMessage["conversation"] = CKRecord.Reference(record: savedConversation, action: .none)
                        
            savedRecords.append(savedConversation)
          }
          savedRecords.append(savedMessage)
                    
          let (saveResult, _) = try await container.publicCloudDatabase.modifyRecords(saving: savedRecords, deleting: [])
          for (_, result) in saveResult {
            switch result {
            case .success(let record) where record.recordType == "Message":
              let message = Message(record: record)
              _ = store.update(messages: [message])
              store.cornversationRecordName = (record["conversation"] as? CKRecord.Reference)?.recordID.recordName
            case .success(let record):
              Log.feedback.debug("\(record.recordType) created")
            case .failure(let error):
              Log.feedback.error(error)
            }
          }
          messagesPublisher.send(store.messages)
          store.save()
                    
          fulfill(.success(()))
        }
      }
      .eraseToAnyPublisher()
    }
                
    return CloudMessagesClient(
      feedbackEnabled: true,
      onAllMessages: {
        messagesPublisher.eraseToAnyPublisher()
      },
      onCheckForMessages: {
        Task {
          do {
            guard try await container.accountStatus() == .available else {
              Log.feedback.debug("Account not available")
              return
            }
            let user = try await container.userRecordID()
            let conversations = try await pullConversations(user: user)
            let messages = try await pullMessages(in: conversations)
            let feedbackMessages = messages.map(Message.init(record:))
            var store = MessagesStore.load()
            store.cornversationRecordName = conversations.last?.recordID.recordName
            let hasUnread = store.update(messages: feedbackMessages)
            store.save()
            unreadPublisher.send(hasUnread)
            messagesPublisher.send(store.messages)
          } catch {
            Log.feedback.error(error)
          }
        }
      },
      onCheckLoggedIn: {
        do {
          let status = try await container.accountStatus()
          return status == .available
        } catch {
          Log.feedback.error(error)
          return false
        }
      },
      onSendMessage: write(message:),
      onUnreadNoticePublisher: {
        unreadPublisher.eraseToAnyPublisher()
      }
    )
  }
}

extension Message {
  init(record: CKRecord) {
    self.init(
      recordName: record.recordID.recordName,
      sentFromApp: (record["sentBy"] as? String ?? "").count == 0,
      sentBy: record["sentBy"] as? String ?? "",
      content: record["body"] as? String ?? "",
      postedAt: record["postedAt"] as? Date ?? Date()
    )
  }
}

extension UIDevice {
  fileprivate func platform() async -> String {
    let device = platformName() ?? "unknown"
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    let systemVersion = systemVersion
    return [device, appVersion, appBuild, systemVersion].joined(separator: "|")
  }
    
  //https://github.com/schickling/Device.swift/blob/master/Device/UIDeviceExtension.swift
  private func platformName() -> String? {
    var systemInfo = utsname()
    uname(&systemInfo)
        
    let machine = systemInfo.machine
    let mirror = Mirror(reflecting: machine)
    var identifier = ""
        
    for child in mirror.children {
      if let value = child.value as? Int8 , value != 0 {
        identifier.append(String(UnicodeScalar(UInt8(value))))
      }
    }
        
    return identifier
  }
}
