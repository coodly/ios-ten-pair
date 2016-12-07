/*
 * Copyright 2016 Coodly LLC
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

import UIKit
import CoreData

#if os(iOS)
private extension Selector {
    static let addMessage = #selector(ConversationViewController.addMessage)
}

internal class ConversationViewController: FetchedTableViewController<Message, MessageCell>, InjectionHandler, PersistenceConsumer {
    var persistence: CorePersistence!
    var conversation: Conversation?
    private lazy var presentedConversation: Conversation = {
        if let c = self.conversation {
            return c
        }
        
        return self.persistence.mainContext.insertEntity() as Conversation
    }()
    
    private var refreshed = false
    var goToCompose = false
    private var showingCompose = false
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMddHHmm")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: .addMessage)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier())
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !refreshed && presentedConversation.shouldFetchMessages() else {
            return
        }
        
        tableView.tableFooterView = FooterLoadingView()
        refreshMessages()
        refreshed = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showingCompose = false
        
        if goToCompose {
            goToCompose = false
            addMessage()
            return
        }
        
        let rows = tableView.numberOfRows(inSection: 0)
        guard rows != 0 else {
            return
        }
        
        tableView.scrollToRow(at: IndexPath(row: rows - 1, section: 0), at: .middle, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if showingCompose {
            return
        }
        
        if presentedConversation.messages?.count != 0 {
            return
        }
        
        persistence.mainContext.delete(presentedConversation)
        persistence.save()
    }
    
    override func createFetchedController() -> NSFetchedResultsController<Message> {
        return persistence.mainContext.fetchedControllerForMessages(in: presentedConversation)
    }
    
    override func configure(cell: MessageCell, at indexPath: IndexPath, with message: Message) {
        let timeString = dateFormatter.string(from: message.postedAt)
        let timeValue: String
        if let sentBy = message.sentBy {
            timeValue = "\(sentBy) - \(timeString)"
        } else {
            timeValue = timeString
        }
        cell.timeLabel.text = timeValue
        cell.messageLabel.text = message.body
        cell.alignment = message.sentBy == nil ? .right : .left
    }
    
    @objc fileprivate func addMessage() {
        showingCompose = true
        let compose = ComposeViewController()
        compose.entryHandler = {
            message in
            
            self.persistence.mainContext.addMessage(message, for: self.presentedConversation)
            self.persistence.save()
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        let navigation = UINavigationController(rootViewController: compose)
        navigation.modalPresentationStyle = .formSheet
        present(navigation, animated: true, completion: nil)
    }
    
    private func refreshMessages() {
        let request = PullMessagesOperation(for: presentedConversation)
        request.completionHandler = {
            success, op in
            
            DispatchQueue.main.async {
                self.tableView.tableFooterView = UIView()
            }
        }
        inject(into: request)
        request.start()
    }
}
#endif
