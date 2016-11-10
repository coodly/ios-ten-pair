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

private extension NSPredicate {
    static let truePredicate = NSPredicate(format: "TRUEPREDICATE")
}

public class CorePersistence {
    private var stack: CoreStack!
    
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
        Logging.log("Perform \(tasks.count) tasks")
        if let task = tasks.first {
            stack.performUsingWorker() {
                context in
                
                task(context)
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

public extension NSManagedObjectContext {
    public func fetch<T: NSManagedObject>(predicate: NSPredicate = .truePredicate, limit: Int? = nil) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            return try fetch(request)
        } catch {
            Logging.log("Fetch \(T.entityName()) failure. Error \(error)")
            return []
        }
    }
    
    public func fetchFirst<T: NSManagedObject>(predicate: NSPredicate = .truePredicate, sort: [NSSortDescriptor] = []) -> T? {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        request.predicate = predicate
        request.fetchLimit = 1
        request.sortDescriptors = sort
        
        do {
            let result = try fetch(request)
            return result.first
        } catch {
            Logging.log("Fetch \(T.entityName()) failure. Error \(error)")
            return nil
        }
    }
    
    public func fetchEntity<T: NSManagedObject, V: Any>(where name: String, hasValue: V) -> T? {
        let attributePredicate = predicate(for: name, withValue: hasValue)
        return fetchFirst(predicate: attributePredicate)
    }
    
    public func predicate<V: Any>(for attribute: String, withValue: V) -> NSPredicate {
        let predicate: NSPredicate
        
        switch(withValue) {
        case is String:
            predicate = NSPredicate(format: "%K ==[c] %@", argumentArray: [attribute, withValue])
        default:
            predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, withValue])
        }
        
        return predicate
    }
    
    public func sumOfDecimalProperty<T: NSManagedObject>(onType type: T.Type, name: String, predicate: NSPredicate = .truePredicate) -> NSDecimalNumber {
        
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: T.entityName())
        request.resultType = .dictionaryResultType
        request.predicate = predicate
        
        let sumKey = "sumOfProperty"
        
        let expression = NSExpressionDescription()
        expression.name = sumKey
        expression.expression = NSExpression(forKeyPath: "@sum.\(name)")
        expression.expressionResultType = .decimalAttributeType
        
        request.propertiesToFetch = [expression]
        
        do {
            let result = try fetch(request)
            if let first = result.first, let value = first[sumKey] as? NSDecimalNumber {
                return value
            }
            
            Logging.log("Will return zero for sum of \(name)")
            
            return NSDecimalNumber.zero
        } catch {
            Logging.log("addDecimalProperty error: \(error)")
            return NSDecimalNumber.notANumber
        }
    }
    
    public func count<T: NSManagedObject>(instancesOf entity: T.Type, predicate: NSPredicate = .truePredicate) -> Int {
        let request: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: T.entityName())
        request.predicate = predicate

        do {
            return try count(for: request)
        } catch let error as NSError {
            fatalError("Count failed: \(error)")
        }
    }
    
    public func fetchedController<T: NSFetchRequestResult>(predicate: NSPredicate? = nil, sort: [NSSortDescriptor], sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sort
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedController.performFetch()
        } catch {
            Logging.log("Fetch error: \(error)")
        }
        
        return fetchedController
    }
    
    public func has<T: NSManagedObject, V: Any>(entity type: T.Type, where attribute: String, is value: V) -> Bool {
        return count(instancesOf: type, predicate: predicate(for: attribute, withValue: value)) == 1
    }
    
    public func inCurrentContext<T: NSManagedObject>(entities: [T]) -> [T] {
        var result = [T]()
        for e in entities {
            result.append(inCurrentContext(entity: e))
        }
        
        return result
    }
    
    public func inCurrentContext<T: NSManagedObject>(entity: T) -> T {
        return object(with: entity.objectID) as! T
    }
    
    public func delete<T: NSManagedObject>(objects: [T]) {
        for d in objects {
            delete(d)
        }
    }
    
    public func fetchAttribute<T: NSManagedObject, Result>(named: String, on entity: T.Type, limit: Int? = nil, predicate: NSPredicate = .truePredicate) -> [Result] {
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: T.entityName())
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [named]
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            let objects = try fetch(request)
            return objects.flatMap { $0[named] as? Result }
        } catch {
            Logging.log("fetchEntityAttribute error: \(error)")
            return []
        }
    }
}

private protocol CoreStack {
    var mainContext: NSManagedObjectContext! { get }
    var managedObjectModel: NSManagedObjectModel! { get set }
    var databaseFilePath: URL? { get }
    func performUsingWorker(closure: ((NSManagedObjectContext) -> ()))
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
    private let identifier: String
    
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

