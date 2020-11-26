/*
* Copyright 2020 Coodly LLC
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
#if canImport(Combine)
import Combine
#endif

extension NSManagedObjectContext {
    @available(iOS 13.0, *)
    public func monitorEntities<Entity: NSManagedObject>(of type: Entity.Type, predicate: NSPredicate = .truePredicate, sort: [NSSortDescriptor] = []) -> AnyPublisher<[Entity], Never> {
        EntitiesChangePublisher(type: type, predicate: predicate, sort: sort, context: self).eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
private struct EntitiesChangePublisher<Entity: NSManagedObject>: Publisher {
    public typealias Output = Array<Entity>
    public typealias Failure = Never
    
    private let type: Entity.Type
    private let predicate: NSPredicate
    private let sort: [NSSortDescriptor]
    private let context: NSManagedObjectContext
    fileprivate init(type: Entity.Type, predicate: NSPredicate, sort: [NSSortDescriptor], context: NSManagedObjectContext) {
        self.type = type
        self.predicate = predicate
        self.sort = sort
        self.context = context
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = EntitiesChangeSubscription(type: type, predicate: predicate, sort: sort, context: context, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13.0, *)
private class EntitiesChangeSubscription<Entity: NSManagedObject, S: Subscriber>: NSObject, NSFetchedResultsControllerDelegate, Subscription where S.Input == Array<Entity>, S.Failure == Never {
    
    private var controller: NSFetchedResultsController<Entity>?
    
    private let type: Entity.Type
    private let predicate: NSPredicate
    private let sort: [NSSortDescriptor]
    private let context: NSManagedObjectContext
    private var subscriber: S?
    fileprivate init(type: Entity.Type, predicate: NSPredicate, sort: [NSSortDescriptor], context: NSManagedObjectContext, subscriber: S) {
        self.type = type
        self.predicate = predicate
        self.sort = sort
        self.subscriber = subscriber
        self.context = context
    }
    
    public func request(_ demand: Subscribers.Demand) {
        guard controller == nil else {
            return
        }
        
        controller = context.fetchedController(predicate: predicate, sort: sort)
        controller?.delegate = self
        forward()
    }
    
    public func cancel() {
        subscriber = nil
        controller?.delegate = nil
        controller = nil
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        forward()
    }
    
    private func forward() {
        _ = subscriber?.receive(controller?.fetchedObjects ?? [])
    }
}

