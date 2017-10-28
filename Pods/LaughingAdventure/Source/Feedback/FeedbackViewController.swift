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
import CloudKit
import CoreData
import CoreDataPersistence

#if os(iOS)
private extension Selector {
    static let donePressed = #selector(FeedbackViewController.donePressed)
    static let addPressed = #selector(FeedbackViewController.addPressed)
    static let refreshConversations = #selector(FeedbackViewController.refresh)
    static let presentNotice = #selector(FeedbackViewController.presentNotice)
}

public class FeedbackViewController: FetchedTableViewController<Conversation, ConversationCell>, InjectionHandler, PersistenceConsumer, FeedbackContainerConsumer, CloudAvailabilityConsumer {
    var persistence: CorePersistence!
    var feedbackContainer: CKContainer!
    var cloudAvailable: Bool!

    private var refreshControl: UIRefreshControl!
    private var accountStatus: CKAccountStatus = .couldNotDetermine
    private var headerLabel: UILabel!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("coodly.feedback.controller.title", comment: "")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .donePressed)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: .addPressed)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: .refreshConversations, for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier())
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        header.backgroundColor = UIColor(white: 0.95, alpha: 1)
        let label = UILabel(frame: CGRect(x: 16, y: 16, width: header.frame.width - 32, height: header.frame.height - 32))
        self.headerLabel = label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: NSLocalizedString("coodly.feedback.header.message", comment: ""), attributes: [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleDouble.rawValue, NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)])
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        header.addSubview(label)
        tableView.tableHeaderView = header
        
        let tapHandler = UITapGestureRecognizer(target: self, action: .presentNotice)
        header.addGestureRecognizer(tapHandler)
        
        tableView.tableFooterView = UIView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = headerLabel.sizeThatFits(CGSize(width: headerLabel.frame.width, height: 1000)).height
        tableView.tableHeaderView!.frame.size.height = height + 32
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if cloudAvailable! {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            let message = FeedbackMessageView()
            message.messageLabel.text = NSLocalizedString("coodly.feedback.sign.in.message", comment: "")
            message.frame = self.view.bounds
            self.view.addSubview(message)
        }
    }
    
    public override func createFetchedController() -> NSFetchedResultsController<Conversation> {
        return persistence.mainContext.fetchedControllerForConversations()
    }
    
    public override func configure(cell: ConversationCell, at indexPath: IndexPath, with converation: Conversation) {
        if let time = converation.lastMessageTime {
            cell.timeLabel.text = "\(dateFormatter.string(from: time)) >"
        } else {
            cell.timeLabel.text = ""
        }
        
        cell.snippetLabel.text =  (converation.hasUpdate ? "● " : "") + (converation.snippet ?? "")
    }
    
    public override func tappedCell(at indexPath: IndexPath, object: Conversation) -> Bool {
        pushConversationController(with: object)
        return true
    }
    
    @objc fileprivate func donePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func addPressed() {
        pushConversationController(with: nil)
    }
    
    private func pushConversationController(with conversation: Conversation?) {
        let conversationController = ConversationViewController()
        conversationController.conversation = conversation
        conversationController.goToCompose = conversation == nil
        inject(into: conversationController)
        navigationController?.pushViewController(conversationController, animated: true)
    }
    
    @objc fileprivate func refresh() {
        Logging.log("Refresh conversations")

        let op = PullConversationsOperation()
        inject(into: op)
        op.completionHandler = {
            success, _ in
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        op.start()
    }
    
    private func checkAccountStatus(completion: @escaping ((Bool) -> ())) {
        Logging.log("Check account")
        feedbackContainer.accountStatus() {
            status, error in
            
            Logging.log("Account status: \(status.rawValue) - \(error)")
            completion(status == .available)
        }
    }
    
    @objc fileprivate func presentNotice() {
        let controller = FeedbackNoticeViewController()
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .formSheet
        present(navigation, animated: true, completion: nil)
    }
}
#endif
