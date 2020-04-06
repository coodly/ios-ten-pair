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

public extension NSPredicate {
    static let truePredicate = NSPredicate(format: "TRUEPREDICATE")
}

extension NSManagedObjectContext {
    public func insertEntity<T: NSManagedObject>() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName(), into: self) as! T
    }
    
    public func fetch<T: NSManagedObject>(predicate: NSPredicate = .truePredicate, sort: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        request.sortDescriptors = sort
        
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
    
    @available(iOS 9, tvOS 9, macOS 10.12, *)
    public func fetchedController<T: NSFetchRequestResult>(predicate: NSPredicate? = nil, sort: [NSSortDescriptor], batchSize: Int = 0, sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sort
        fetchRequest.fetchBatchSize = batchSize
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
    
    public func fetchAttribute<T: NSManagedObject, Result>(named: String, on entity: T.Type, limit: Int? = nil, predicate: NSPredicate = .truePredicate, distinctResults: Bool = false) -> [Result] {
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: T.entityName())
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [named]
        request.returnsDistinctResults = distinctResults
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            let objects = try fetch(request)
            return objects.compactMap({ $0[named] as? Result })
        } catch {
            Logging.log("fetchEntityAttribute error: \(error)")
            return []
        }
    }
}
