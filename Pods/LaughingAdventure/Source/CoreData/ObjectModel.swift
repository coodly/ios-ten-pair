/*
* Copyright 2015 Coodly LLC
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

import CoreData

private let SavingContextName = "Saving"
private let MainContextName = "Main"

@available(*, deprecated, message: "Use CorePersistence")
public class ObjectModel {
    struct StackConfig {
        var storeType: String!
        var storeURL: URL!
        var options: [NSObject: AnyObject]?
    }

    private var modelName: String!
    private var storeType: String!
    private var inDirectory: FileManager.SearchPathDirectory!
    private var pathToSQLiteFile: URL?
    private var writingContext: NSManagedObjectContext?
    public var wipeDatabaseOnConflict = false
    private static var spawnedBackgroundCount = 0
    
    public init() {
        fatalError("Use some other init method instead")
    }
    
    public convenience init(modelName: String) {
        self.init(modelName: modelName, storeType: NSSQLiteStoreType)
    }
    
    public init(modelName: String, storeType: String, inDirectory: FileManager.SearchPathDirectory = .documentDirectory) {
        self.modelName = modelName
        self.storeType = storeType
        self.inDirectory = inDirectory
    }
    
    public init(modelName: String, pathToSQLiteFile: URL) {
        self.modelName = modelName
        self.pathToSQLiteFile = pathToSQLiteFile
        storeType = NSSQLiteStoreType
    }
    
    public init(parentContext: NSManagedObjectContext) {
        writingContext = parentContext
    }
    
    public func spawnBackgroundInstance() -> ObjectModel {
        fatalError("Please overwrite this method and instantiate your subclass \(#function)")
    }
    
    lazy public var managedObjectContext: NSManagedObjectContext = {
        var isPrivateInstance = false
        
        let mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        
        if let _ = self.writingContext {
            isPrivateInstance = true
        } else {
            let saving = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            saving.persistentStoreCoordinator = self.persistentStoreCoordinator
            saving.mergePolicy = mergePolicy
            self.writingContext = saving
            saving.name = SavingContextName
        }
        
        var managedContext = NSManagedObjectContext(concurrencyType: (isPrivateInstance ? .privateQueueConcurrencyType : .mainQueueConcurrencyType))
        if isPrivateInstance {
            spawnedBackgroundCount += 1
            managedContext.name = "Worker \(spawnedBackgroundCount)"
            Logging.log("Spawned worker \(spawnedBackgroundCount)")
        } else {
            managedContext.name = MainContextName
        }
        managedContext.parent = self.writingContext
        managedContext.mergePolicy = mergePolicy
        
        return managedContext
    }()

    
    public lazy var workingFilesDirectory: URL = {
        let urls = FileManager.default.urls(for: self.inDirectory, in: .userDomainMask)
        let last = urls.last!
        let identifier = Bundle.main.bundleIdentifier!
        let dbIdentifier = identifier + ".db"
        let dbFolder = last.appendingPathComponent(dbIdentifier)
        do {
            try FileManager.default.createDirectory(at: dbFolder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Create db folder error \(error)")
        }
        return dbFolder
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.databaseFilePath()

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
    
    public func databaseFileExists() -> Bool {
        guard storeType == NSSQLiteStoreType else {
            return false
        }
        
        guard let filePath = databaseFilePath() else {
            return false
        }
        
        let path = filePath.path
        return FileManager.default.fileExists(atPath: path)
    }
    
    private func databaseFilePath() -> URL? {
        if let existing = pathToSQLiteFile {
            return existing
        } else if self.storeType == NSSQLiteStoreType {
            //TODO jaanus: check this ! here
            return workingFilesDirectory.appendingPathComponent("\(self.modelName!).sqlite")
        } else {
            return nil
        }
    }
    
    public func saveContext () {
        saveContext(nil)
    }
    
    public func saveContext(_ completion: (() -> Void)?) {
        saveContext(managedObjectContext, completion: completion)
    }
    
    public func saveInBlock(_ handler: @escaping ((ObjectModel) -> Void)) {
        saveInBlock(handler, completion: nil)
    }

    public func saveInBlock(_ handler: @escaping ((ObjectModel) -> Void), completion: (() -> ())?) {
        let spawned = spawnBackgroundInstance()
        Logging.log("Spawned worker from \(managedObjectContext.name!)")
        spawned.performBlock { () -> () in
            handler(spawned)
            spawned.saveContext(completion)
        }
    }

    public func performBlock(_ block: @escaping (() -> ())) {
        Logging.log("Perform block on \(managedObjectContext.name!)")
        managedObjectContext.perform(block)
    }
    
    private func saveContext(_ context: NSManagedObjectContext, completion: (() -> Void)?) {
        Logging.log("Save \(context.name!)")
        context.perform { () -> Void in
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    Logging.log("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            
            if let parent = context.parent {
                self.saveContext(parent, completion: nil)
            }
            
            guard let action = completion else {
                return
            }
            
            DispatchQueue.main.async(execute: action)
        }
    }
}

#if os(iOS)
// MARK: - Fetched controller
public extension ObjectModel {
    public func fetchedControllerForEntity<T: NSFetchRequestResult>(_ type: T.Type, sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<T> {
        return fetchedControllerForEntity(type, predicate: nil, sortDescriptors: sortDescriptors, sectionNameKeyPath: sectionNameKeyPath)
    }

    public func fetchedControllerForEntity<T: NSFetchRequestResult>(_ type: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = fetchRequestForEntity(named: type.entityName(), predicate: predicate, sortDescriptors: sortDescriptors)
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedController.performFetch()
        } catch {
            Logging.log("Fetch error: \(error)")
        }
        
        return fetchedController
    }
}
#endif

public extension ObjectModel /* Fetch request */ {
    
    public func fetchRequestForEntity<T: NSManagedObject>(_ type: T.Type) -> NSFetchRequest<T> {
        return fetchRequestForEntity(type, predicate: nil, sortDescriptors: [])
    }
    
    public func fetchRequestForEntity<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate) -> NSFetchRequest<T> {
        return fetchRequestForEntity(type, predicate: predicate, sortDescriptors: [])
    }
    
    public func fetchRequestForEntity<T: NSManagedObject>(_ type: T.Type, sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<T> {
        return fetchRequestForEntity(type, predicate: nil, sortDescriptors: sortDescriptors)
    }
    
    public func fetchRequestForEntity<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<T> {
        return fetchRequestForEntity(named: type.entityName(), predicate: predicate, sortDescriptors: sortDescriptors)
    }

    fileprivate func fetchRequestForEntity<T: NSFetchRequestResult>(named name: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: name)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
}

public extension ObjectModel /* Delete */ {
    public func deleteObjects(_ objects: [NSManagedObject], saveAfter: Bool = true) {
        for obj in objects {
            deleteObject(obj, saveAfter: false)
        }
        
        if saveAfter {
            saveContext()
        }
    }
    
    public func deleteObject(_ object: NSManagedObject, saveAfter: Bool = true) {
        managedObjectContext.delete(object)
        
        if saveAfter {
            saveContext()
        }
    }
}

// MARK: - Queries
public extension ObjectModel {
    public func hasEntity<T: NSManagedObject>(_ type: T.Type, attribute: String, hasValue: AnyObject) -> Bool {
        let predicate = predicateForAttribute(attribute, withValue: hasValue)
        return countInstancesOfEntity(type, usingPredicate: predicate) == 1
    }
    
    public func countInstancesOfEntity<T: NSManagedObject>(_ type: T.Type, usingPredicate predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE")) -> Int {
        let request: NSFetchRequest<NSNumber> = fetchRequestForEntity(named: type.entityName(), predicate: predicate, sortDescriptors: [])
        do {
            let count = try managedObjectContext.count(for: request)
            return count
        } catch let error as NSError {
            fatalError("Count failed: \(error)")
        }
    }
    
    public func fetchEntity<T: NSManagedObject>(_ type: T.Type, whereAttribute: String, hasValue: AnyObject) -> T? {
        let predicate = predicateForAttribute(whereAttribute, withValue: hasValue)
        return fetchFirstEntity(type, predicate: predicate)
    }
    
    public func fetchFirstEntity<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor] = []) -> T? {
        let request = fetchRequestForEntity(type, predicate: predicate, sortDescriptors: sortDescriptors)
        
        do {
            let result = try managedObjectContext.fetch(request)
            return result.first
        } catch {
            Logging.log(error)
            return nil
        }
    }

    public func fetchEntity<T: NSManagedObject>(whereAttribute name: String, hasValue: AnyObject) -> T? {
        let predicate = predicateForAttribute(name, withValue: hasValue)
        return fetchFirstEntity(usingPredicate: predicate)
    }
    
    public func fetchFirstEntity<T: NSManagedObject>(usingPredicate predicate: NSPredicate, sortDescriptors: [NSSortDescriptor] = []) -> T? {
        let request: NSFetchRequest<T> = fetchRequestForEntity(named: T.entityName(), predicate: predicate, sortDescriptors: sortDescriptors)
        
        do {
            let result = try managedObjectContext.fetch(request)
            return result.first
        } catch {
            Logging.log(error)
            return nil
        }
    }

    public func fetchAllEntitiesOfType<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), limit: Int = 0) -> [T] {
        let request = fetchRequestForEntity(type, predicate: predicate)
        if limit > 0 {
            request.fetchLimit = limit
        }
        
        do {
            let result = try managedObjectContext.fetch(request)
            return result
        } catch {
            Logging.log(error)
            return []
        }
    }
    
    public func fetchEntityAttribute<T: NSManagedObject>(_ type: T.Type, attributeName: String) -> [AnyObject] {
        let request: NSFetchRequest<NSDictionary> = fetchRequestForEntity(named: type.entityName(), predicate: nil, sortDescriptors: [])
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [attributeName]
        
        do {
            let objects = try managedObjectContext.fetch(request)
            return objects.map { $0[attributeName] as AnyObject }
        } catch {
            Logging.log("fetchEntityAttribute error: \(error)")
            return []
        }
    }
    
    public func sumOfDecimalProperty<T: NSManagedObject>(onType type: T.Type, name: String, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE")) -> NSDecimalNumber {

        return managedObjectContext.sumOfDecimalProperty(onType: type, name: name, predicate: predicate)
    }
}

public extension ObjectModel {
    public func entitiesInCurrentContext<T: NSManagedObject>(_ entities: [T]) -> [T] {
        var result = [T]()
        for entity in entities {
            result.append(entityInCurrentContext(entity))
        }
        
        return result
    }

    public func entityInCurrentContext<T: NSManagedObject>(_ entity: T) -> T {
        return managedObjectContext.object(with: entity.objectID) as! T
    }
}

// MARK: - Predicates
public extension ObjectModel {
    public func predicateForAttribute(_ attributeName: String, withValue: AnyObject) -> NSPredicate {
        let predicate: NSPredicate
        
        switch(withValue) {
        case is String:
            predicate = NSPredicate(format: "%K ==[c] %@", argumentArray: [attributeName, withValue])
        default:
            predicate = NSPredicate(format: "%K = %@", argumentArray: [attributeName, withValue])
        }
        
        return predicate
    }
}
