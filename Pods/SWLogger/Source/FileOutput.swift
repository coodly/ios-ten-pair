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

import Foundation

public class FileOutput: LogOutput {
    private var fileHandle: NSFileHandle!
    private let saveInDirectory: NSSearchPathDirectory

    public init(saveInDirectory: NSSearchPathDirectory = .DocumentDirectory) {
        self.saveInDirectory = saveInDirectory
    }
    
    public func printMessage(message: String) {
        let written = "\(message)\n"
        let data = written.dataUsingEncoding(NSUTF8StringEncoding)!
        if let handle = handle() {
            handle.writeData(data)
        }
    }
    
    private func handle() -> NSFileHandle? {
        if let handle = fileHandle {
            return handle
        }

        let dir = NSFileManager.defaultManager().URLsForDirectory(saveInDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last as NSURL!
        let time = dateFormatter.stringFromDate(NSDate())
        let logsFolder = dir.URLByAppendingPathComponent("Logs")
        createFolder(logsFolder)
        let fileURL = logsFolder.URLByAppendingPathComponent("\(time).txt")
        
        makeSureFileExists(fileURL)
        
        do {
            if let opened: NSFileHandle = try NSFileHandle(forWritingToURL: fileURL) {
                opened.seekToEndOfFile()
                fileHandle = opened
                
                return fileHandle
            } else {
                print("Could not open log file 1")
                
                return nil
            }
        } catch let error as NSError {
            print("\(error)")
            
            return nil
        }
    }

    private func createFolder(path: NSURL) {
        if NSFileManager.defaultManager().fileExistsAtPath(path.path!) {
            return
        }
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Create logs folder error \(error)")
        }
    }
    
    private func makeSureFileExists(atURL: NSURL) {
        if NSFileManager.defaultManager().fileExistsAtPath(atURL.path!) {
            return
        }
        
        NSData().writeToURL(atURL, atomically: true)
    }
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        return formatter
    }()
}