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

#if canImport(PuffLogger)
import PuffLogger
#endif

open class ConcurrentOperation: Operation {
    public var cancelOnDependencyFailure = true
    
    private struct Forward {
        fileprivate let callSuccess: (() -> Void)
        fileprivate let callError: ((Error) -> Void)
        
        internal func forwardSuccess() {
            callSuccess()
        }
        
        internal func forward(error: Error) {
            callError(error)
        }
    }
    
    public func onCompletion<T: ConcurrentOperation>(callback: @escaping ((Result<T, Error>) -> Void)) {
        let onSuccess: (() -> Void) = {
            [unowned self] in
            
            callback(.success(self as! T))
        }
        let onError: ((Error) -> Void) = {
            error in
            
            callback(.failure(error))
        }
        forward = Forward(callSuccess: onSuccess, callError: onError)
    }
    
    private var forward: Forward?
    
    override open var isConcurrent: Bool {
        return true
    }

    private var failureError: Error?
    
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
        Logging.log("Start \(String(describing: type(of: self)))")
        if isCancelled {
            finish()
            return
        }
        
        if cancelOnDependencyFailure, let depencencyError = anyDependencyError {
            Logging.log("Dependency had error: \(depencencyError)")
            let failure = NSError(domain: "com.coodly.concurrent", code: 0, userInfo: [NSUnderlyingErrorKey: depencencyError])
            finish(failure)
            return
        }
        
        if completionBlock != nil {
            Logging.log("Existing completion block. Will not add own handling")
        } else {
            completionBlock = {
                [unowned self] in
                
                guard let forward = self.forward else {
                    return
                }
                
                if let error = self.failureError {
                    forward.forward(error: error)
                } else {
                    forward.forwardSuccess()
                }
            }
        }
        
        self.myExecuting = true
        
        main()
    }
    
    public func finish(_ failure: Error? = nil) {
        Logging.log("Finish \(String(describing: type(of: self)))")
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")
        myExecuting = false
        myFinished = true
        failureError = failure
        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
    
    internal var anyDependencyError: Error? {
        return dependencies.compactMap({ $0 as? ConcurrentOperation }).compactMap({ $0.failureError }).first
    }
}
