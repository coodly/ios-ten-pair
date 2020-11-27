/*
 * Copyright 2017 Coodly LLC
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

import CloudKit
import CoreDataPersistence
#if canImport(Combine)
import Combine
#endif

private typealias Dependencies = PersistenceConsumer

public final class Feedback: Dependencies, FeedbackInjector {
    var persistence: CorePersistence!
    
    @available(iOS 13.0, *)
    private lazy var disposeBag = Set<AnyCancellable>()
    
    @available(iOS 13.0, *)
    private(set) public lazy var unreadStatus = CurrentValueSubject<Bool, Never>(false)
    
    public var hasUnreadMessages: Bool {
        var hasUnread = false
        persistence.write() {
            context in
            
            hasUnread = context.hasUnseenConversations()
        }
        return hasUnread
    }
    
    internal let container: CKContainer
    internal lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()
    
    public init(container: CKContainer = .default(), translation: Translation? = nil, styling: Styling? = nil) {
        Logging.log("Start with \(String(describing: container.containerIdentifier))")
        self.container = container
        FeedbackInjection.sharedInstance.feedbackContainer = container
        if let translation = translation {
            FeedbackInjection.sharedInstance.translation = translation
        }
        if let styling = styling {
            FeedbackInjection.sharedInstance.styling = styling
        }
    }
    
    public func load() {
        inject(into: self)
        
        persistence.loadPersistentStores() {
            Logging.log("Database loaded")
            
            FeedbackInjection.sharedInstance.setUp()
            
            guard #available(iOS 13, *) else {
                return
            }
            
            self.loadUnreadMonitor()
        }
    }
    
    @available(iOS 13.0, *)
    private func loadUnreadMonitor() {
        Logging.log("Load unread monitor")
        persistence.mainContext.unreadConversations
            .map(\.count)
            .receive(on: DispatchQueue.main)
            .sink() {
                [unreadStatus]
                
                update in
                
                unreadStatus.send(update > 0)
            }
            .store(in: &disposeBag)
    }
}
