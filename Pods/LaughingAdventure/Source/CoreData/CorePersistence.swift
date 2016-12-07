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

import Foundation
import CoreData

public typealias ContextClosure = (NSManagedObjectContext) -> ()

public class CorePersistence {
    fileprivate var stack: CoreStack!
    
    public var sqliteFilePath: URL? {
        return stack.databaseFilePath
    }
    
    public lazy var mainContext: NSManagedObjectContext = {
        let context = self.stack.mainContext!
        context.name = "Main"
        return context
    }()
    
    public var managedObjectModel: NSManagedObjectModel {
        set {
            self.stack.managedObjectModel = newValue
        }
        get {
            return self.stack.managedObjectModel
        }
    }
    
    public init(modelName: String, storeType: String = NSSQLiteStoreType, identifier: String = Bundle.main.bundleIdentifier!, in directory: FileManager.SearchPathDirectory = .documentDirectory, wipeOnConflict: Bool = false) {
        stack = LegacyCoreStack(modelName: modelName, type: storeType, identifier: identifier, in: directory, wipeOnConflict: wipeOnConflict)
    }
    
    public func perform(wait: Bool = true, block: @escaping ContextClosure) {
        let context = stack.mainContext!
        
        if wait {
            context.performAndWait {
                block(context)
            }
        } else {
            context.perform {
                block(context)
            }
        }
    }
    
    public func performInBackground(task: @escaping ContextClosure) {
        performInBackground(task: task, completion: nil)
    }
    
    public func performInBackground(task: @escaping ContextClosure, completion: (() -> ())? = nil) {
        performInBackground(tasks: [task], completion: completion)
    }

    public func performInBackground(tasks: [ContextClosure], completion: (() -> ())? = nil) {
        Logging.log("Perform \(tasks.count) tasks on \(stack.identifier)")
        if let task = tasks.first {
            stack.performUsingWorker() {
                context in
                
                let start = CFAbsoluteTimeGetCurrent()
                task(context)
                let elapsed = CFAbsoluteTimeGetCurrent() - start
                Logging.log("Task execution time \(elapsed) seconds")
                self.save(context: context) {
                    var remaining = tasks
                    _ = remaining.removeFirst()
                    self.performInBackground(tasks: remaining, completion: completion)
                }
            }
        } else if let completion = completion {
            Logging.log("All complete")
            completion()
        }
    }
    
    public func save(completion: (() -> ())? = nil) {
        guard let context = stack.mainContext else {
            return
        }
        
        save(context: context, completion: completion)
    }
    
    private func save(context: NSManagedObjectContext, completion: (() -> ())? = nil) {
        context.perform {
            if context.hasChanges {
                Logging.log("Save \(context.name)")
                try! context.save()
            }
            
            if let parent = context.parent {
                self.save(context: parent)
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
}

// MARK: -
// MARK: Batch delete
extension CorePersistence {
    public func delete<T: NSManagedObject>(entities: T.Type, predicate: NSPredicate = .truePredicate) {
        Logging.log("Batch delete on \(T.entityName())")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName())
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeCount
        do {
            let result = try stack.persistentStoreCoordinator.execute(deleteRequest, with: stack.mainContext) as? NSBatchDeleteResult
            Logging.log("Deleted \(result?.result ?? 0) instances of \(T.entityName())")
        } catch {
            Logging.log("Batch delete error \(error)")
        }
    }
}

private protocol CoreStack {
    var mainContext: NSManagedObjectContext! { get }
    var managedObjectModel: NSManagedObjectModel! { get set }
    var databaseFilePath: URL? { get }
    func performUsingWorker(closure: ((NSManagedObjectContext) -> ()))
    var identifier: String { get }
    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get }
}

@available(iOS 10, *)
@available(tvOS 10.0, *)
private class CoreDataStack: CoreStack {
    fileprivate var databaseFilePath: URL?
    private let modelName: String!
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores {
            storeDescription, error in
            
            print(">>>>>>>>> Store: \(storeDescription)")
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

        }
        return container
    }()
    fileprivate var mainContext: NSManagedObjectContext! {
        return container.viewContext
    }
    fileprivate var managedObjectModel: NSManagedObjectModel!
    fileprivate var identifier: String {
        return "TODO: jaanus"
    }
    fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        fatalError()
    }
    
    private var workerCount = 0
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    fileprivate func performUsingWorker(closure: ((NSManagedObjectContext) -> ())) {
        
    }

    private func performBackgroundTask(closure: @escaping ((NSManagedObjectContext) -> ())) {
        Logging.log("Main: \(container.viewContext) - \(container.viewContext.parent) - \(container.viewContext.persistentStoreCoordinator)")
        container.performBackgroundTask() {
            context in
            
            if context.name == nil {
                self.workerCount += 1
                context.name = "Worker \(self.workerCount)"
            }
            
            Logging.log(">>> \(context) - \(context.parent) - \(context.persistentStoreCoordinator)")
            
            closure(context)
        }
    }
}

private let SavingContextName = "Saving"
private let MainContextName = "Main"
private class LegacyCoreStack: CoreStack {
    struct StackConfig {
        var storeType: String!
        var storeURL: URL!
        var options: [NSObject: AnyObject]?
    }

    fileprivate var mainContext: NSManagedObjectContext! {
        return managedObjectContext
    }
    
    private let modelName: String
    private let storeType: String
    private let directory: FileManager.SearchPathDirectory
    private var writingContext: NSManagedObjectContext?
    private var wipeDatabaseOnConflict = false
    private var pathToSQLiteFile: URL?
    private let mergePolicy: NSMergePolicyType
    fileprivate let identifier: String
    
    private static var spawnedBackgroundCount = 0
    
    init(modelName: String, type: String = NSSQLiteStoreType, identifier: String, in directory: FileManager.SearchPathDirectory = .documentDirectory, mergePolicy: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType, wipeOnConflict: Bool) {
        self.modelName = modelName
        self.storeType = type
        self.directory = directory
        self.mergePolicy = mergePolicy
        self.wipeDatabaseOnConflict = wipeOnConflict
        self.identifier = identifier
    }
    
    fileprivate func performUsingWorker(closure: ((NSManagedObjectContext) -> ())) {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        LegacyCoreStack.spawnedBackgroundCount += 1
        managedContext.name = "Worker \(LegacyCoreStack.spawnedBackgroundCount)"
        managedContext.parent = managedObjectContext
        managedContext.mergePolicy = NSMergePolicy(merge: mergePolicy)
        
        closure(managedContext)
    }
    
    lazy public var managedObjectContext: NSManagedObjectContext = {
        Logging.log("Creating main context for \(self.identifier) - \(Thread.current.isMainThread)")
        assert(Thread.current.isMainThread, "Main context should be crated on main thread")

        let mergePolicy = NSMergePolicy(merge: self.mergePolicy)
        
        let saving = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        saving.persistentStoreCoordinator = self.persistentStoreCoordinator
        saving.mergePolicy = mergePolicy
        self.writingContext = saving
        saving.name = SavingContextName
        
        var managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedContext.name = MainContextName
        managedContext.parent = self.writingContext
        managedContext.mergePolicy = mergePolicy
        
        return managedContext
    }()
    
    
    public lazy var workingFilesDirectory: URL = {
        let urls = FileManager.default.urls(for: self.directory, in: .userDomainMask)
        let last = urls.last!
        let dbIdentifier = self.identifier + ".db"
        let dbFolder = last.appendingPathComponent(dbIdentifier)
        do {
            try FileManager.default.createDirectory(at: dbFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Create db folder error \(error)")
        }
        return dbFolder
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel! = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.databaseFilePath
        
        Logging.log("Using DB file at \(url)")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption as NSObject: true as AnyObject, NSInferMappingModelAutomaticallyOption as NSObject: true as AnyObject]
        let config = StackConfig(storeType: self.storeType, storeURL: url, options: options)
        
        if !self.addPersistentStore(coordinator, config: config, abortOnFailure: !self.wipeDatabaseOnConflict) && self.wipeDatabaseOnConflict {
            Logging.log("Will delete DB")
            try! FileManager.default.removeItem(at: url!)
            _ = self.addPersistentStore(coordinator, config: config, abortOnFailure: true)
        }
        
        return coordinator
    }()
    
    private func addPersistentStore(_ coordinator: NSPersistentStoreCoordinator, config: StackConfig, abortOnFailure: Bool) -> Bool {
        do {
            try coordinator.addPersistentStore(ofType: config.storeType, configurationName: nil, at: config.storeURL, options: config.options)
            return true
        } catch {
            // Report any error we got.
            let failureReason = "There was an error creating or loading the application's saved data."
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            Logging.log("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        if abortOnFailure {
            abort()
        }
        
        return false
    }
    
    fileprivate var databaseFilePath: URL? {
        if let existing = pathToSQLiteFile {
            return existing
        } else if self.storeType == NSSQLiteStoreType {
            //TODO jaanus: check this ! here
            return workingFilesDirectory.appendingPathComponent("\(self.modelName).sqlite")
        } else {
            return nil
        }
    }
}

