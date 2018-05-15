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

open class CorePersistence {
    fileprivate var stack: CoreStack!
    
    public var sqliteFilePath: URL? {
        return stack.databaseFilePath
    }
    
    public lazy var mainContext: NSManagedObjectContext = {
        let context = self.stack.mainContext
        context.name = "Main"
        return context
    }()
    
    public var managedObjectModel: NSManagedObjectModel {
        set {
            self.stack.managedObjectModel = newValue
        }
        get {
            return self.stack.managedObjectModel!
        }
    }
    
    public init(modelName: String, storeType: String = NSSQLiteStoreType, identifier: String = Bundle.main.bundleIdentifier!, bundle: Bundle = Bundle.main, in directory: FileManager.SearchPathDirectory = .documentDirectory, wipeOnConflict: Bool = false) {
        stack = LegacyDataStack(modelName: modelName, type: storeType, identifier: identifier, bundle: bundle, in: directory, wipeOnConflict: wipeOnConflict)

        /*if #available(iOS 10, tvOS 10, *) {
            stack = CoreDataStack(modelName: modelName, type: storeType, identifier: identifier, in: directory, wipeOnConflict: wipeOnConflict)
        } else {
            stack = LegacyDataStack(modelName: modelName, type: storeType, identifier: identifier, in: directory, wipeOnConflict: wipeOnConflict)
        }*/
    }
    
    public func loadPersistentStores(completion: @escaping (() -> ())) {
        stack.loadPersistentStores(completion: completion)
    }
    
    public func perform(wait: Bool = true, block: @escaping ContextClosure) {
        let context = stack.mainContext
        
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
        save(context: stack.mainContext, completion: completion)
    }
    
    private func save(context: NSManagedObjectContext, completion: (() -> ())? = nil) {
        context.perform {
            guard context.hasChanges else {
                Logging.log("No changes")
                completion?()
                return
            }
            
            Logging.log("Save \(String(describing: context.name))")
            guard context.parent != nil || (context.persistentStoreCoordinator?.persistentStores.count ?? 0) > 0 else {
                assert(self.stack.type == NSInMemoryStoreType)
                return
            }
            
            try! context.save()
            
            if let parent = context.parent {
                self.save(context: parent)
            }
            
            completion?()
        }
    }
    
    public func write(block: @escaping ContextClosure) {
        perform(wait: true, block: block)
        save()
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

private class CoreStack {
    fileprivate let modelName: String
    fileprivate let type: String
    fileprivate let identifier: String
    fileprivate let bundle: Bundle
    private let directory: FileManager.SearchPathDirectory
    fileprivate let mergePolicy: NSMergePolicyType
    fileprivate let wipeOnConflict: Bool
    fileprivate var managedObjectModel: NSManagedObjectModel?
    fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        fatalError()
    }
    internal var mainContext: NSManagedObjectContext {
        fatalError()
    }
    
    init(modelName: String, type: String = NSSQLiteStoreType, identifier: String, bundle: Bundle, in directory: FileManager.SearchPathDirectory = .documentDirectory, mergePolicy: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType, wipeOnConflict: Bool) {
        
        self.modelName = modelName
        self.type = type
        self.identifier = identifier
        self.bundle = bundle
        self.directory = directory
        self.mergePolicy = mergePolicy
        self.wipeOnConflict = wipeOnConflict
    }
    
    fileprivate var databaseFilePath: URL? {
        if type == NSSQLiteStoreType {
            return workingFilesDirectory.appendingPathComponent("\(self.modelName).sqlite")
        } else {
            return nil
        }
    }
    
    private lazy var workingFilesDirectory: URL = {
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
    
    fileprivate func performUsingWorker(closure: @escaping ((NSManagedObjectContext) -> ())) {
        let context = self.newBackgroundContext()
        context.perform {
            closure(context)
        }
    }
    
    fileprivate func newBackgroundContext() -> NSManagedObjectContext {
        fatalError()
    }
    
    fileprivate func loadPersistentStores(completion: @escaping (() -> ())) {
        fatalError()
    }
}

@available(iOS 10, tvOS 10.0, macOS 10.12, *)
private class CoreDataStack: CoreStack {
    private lazy var container: NSPersistentContainer = {
        let container: NSPersistentContainer
        if let model = self.managedObjectModel {
            container = NSPersistentContainer(name: self.modelName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: self.modelName)
        }
        
        let config = NSPersistentStoreDescription()
        config.url = self.databaseFilePath
        config.type = self.type
        container.persistentStoreDescriptions = [config]
        
        return container
    }()

    override var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    override var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return container.persistentStoreCoordinator
    }
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: self.mergePolicy)
        return context
    }
    
    fileprivate override func loadPersistentStores(completion: @escaping (() -> ())) {
        assert(container.managedObjectModel != nil)
        container.loadPersistentStores {
            storeDescription, error in
            
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            try! self.container.viewContext.setQueryGenerationFrom(.current)
            self.container.viewContext.mergePolicy = NSMergePolicy(merge: self.mergePolicy)
            
            Logging.log("Store: \(storeDescription)")
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            DispatchQueue.main.async(execute: completion)
        }
    }
}

private class LegacyDataStack: CoreStack {
    struct StackConfig {
        var storeType: String!
        var storeURL: URL!
        var options: [NSObject: AnyObject]?
    }
    
    override var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return coordinator
    }
    
    override var mainContext: NSManagedObjectContext {
        return managedObjectContext
    }
    
    private var writingContext: NSManagedObjectContext?

    fileprivate override func loadPersistentStores(completion: @escaping (() -> ())) {
        DispatchQueue.main.async {
            // touch/create context on main thread
            let _ = self.managedObjectContext

            // Load store on background thread
            DispatchQueue.global(qos: .background).async {
                let url = self.databaseFilePath
                
                Logging.log("Using DB file at \(String(describing: url))")
                
                let options = [NSMigratePersistentStoresAutomaticallyOption as NSObject: true as AnyObject, NSInferMappingModelAutomaticallyOption as NSObject: true as AnyObject]
                let config = StackConfig(storeType: self.type, storeURL: url, options: options)
                
                if !self.addPersistentStore(self.persistentStoreCoordinator, config: config, abortOnFailure: !self.wipeOnConflict) && self.wipeOnConflict {
                    Logging.log("Will delete DB")
                    try! FileManager.default.removeItem(at: url!)
                    _ = self.addPersistentStore(self.persistentStoreCoordinator, config: config, abortOnFailure: true)
                }
                
                DispatchQueue.main.async(execute: completion)
            }
        }
    }
    
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
    
    private lazy var coordinator: NSPersistentStoreCoordinator = {
        let model = self.managedObjectModel ?? self.objectModel
        return NSPersistentStoreCoordinator(managedObjectModel: model)
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        Logging.log("Creating main context for \(self.identifier) - \(Thread.current.isMainThread)")
        assert(Thread.current.isMainThread, "Main context should be crated on main thread")
        
        let mergePolicy = NSMergePolicy(merge: self.mergePolicy)
        
        let saving = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        saving.persistentStoreCoordinator = self.persistentStoreCoordinator
        saving.mergePolicy = mergePolicy
        self.writingContext = saving
        saving.name = "Saving"
        
        var managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedContext.name = "Main"
        managedContext.parent = self.writingContext
        managedContext.mergePolicy = mergePolicy
        
        return managedContext
    }()
    
    private lazy var objectModel: NSManagedObjectModel = {
        let modelURL = self.bundle.url(forResource: self.modelName, withExtension: "momd")!
        return makeOptional(NSManagedObjectModel(contentsOf: modelURL))!
    }()
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.parent = managedObjectContext
        managedContext.mergePolicy = NSMergePolicy(merge: mergePolicy)
        return managedContext
    }
}

//TODO jaanus: remove this. Issue in Xcode9 b5
private func makeOptional<T>(_ value: T?) -> T? {
    return value
}

