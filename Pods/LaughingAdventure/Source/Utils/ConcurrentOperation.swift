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

open class ConcurrentOperation: Operation {
    public var completionHandler: ((Bool, ConcurrentOperation) -> ())?
    
    override open var isConcurrent: Bool {
        return true
    }

    private var failed = false
    
    private var myExecuting: Bool = false
    override public final var isExecuting: Bool {
        get {
            return myExecuting
        }
        set {
            if myExecuting != newValue {
                willChangeValue(forKey: "isExecuting")
                myExecuting = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var myFinished: Bool = false;
    override public final var isFinished: Bool {
        get {
            return myFinished
        }
        set {
            if myFinished != newValue {
                willChangeValue(forKey: "isFinished")
                myFinished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override public final func start() {
        if isCancelled {
            finish()
            return
        }
        
        if completionBlock != nil {
            Logging.log("Existing completion block. Will not add own handling")
        } else {
            completionBlock = {
                [unowned self] in
                
                guard let completion = self.completionHandler else {
                    return
                }
                
                completion(!self.failed, self)
            }
        }
        
        self.myExecuting = true
        
        main()
    }
    
    public func finish(_ failed: Bool = false) {
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        myExecuting = false
        myFinished = true
        self.failed = failed
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
}
