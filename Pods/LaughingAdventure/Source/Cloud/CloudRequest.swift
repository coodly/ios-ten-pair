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
import CloudKit

public enum UsedDatabase {
    case `public`
    case `private`
}

public protocol CloudRequest {
    associatedtype Model
    associatedtype Predicate
    
    func save(record: Model, inDatabase db: UsedDatabase)
    func save(records: [Model], delete: [CKRecordID], inDatabase db: UsedDatabase)
    func delete(record: Model, inDatabase db: UsedDatabase)
    func fetch(predicate: Predicate, sort: [NSSortDescriptor], limit: Int?, pullAll: Bool, inDatabase db: UsedDatabase)
    func fetchFirst(predicate: Predicate, sort: [NSSortDescriptor], inDatabase db: UsedDatabase)
}
