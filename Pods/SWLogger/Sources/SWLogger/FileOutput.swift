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

open class FileOutput: LogOutput {
    public enum Keep: Equatable {
        case forever
        case days(Int)
        case number(Int)
    }
    
    public enum FileTime {
        case minuteBased
        case dateBased
    }
    
    private var fileHandle: FileHandle!
    private let saveInDirectory: FileManager.SearchPathDirectory
    private let appGroup: String?
    private lazy var appGroupFolder: URL? = {
        guard let name = appGroup else {
            return nil
        }
        
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: name)
    }()
    internal lazy var searchPathFolder: URL = {
        FileManager.default.urls(for: self.saveInDirectory, in: .userDomainMask).last!
    }()
    private lazy var appNamePrefix: String = {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        guard let appName = displayName ?? bundleName, !appName.isEmpty else {
            return ""
        }
        
        return "\(appName)-"
    }()
    private let proposedName: String?
    private(set) lazy var logsFolder: URL = {
        let used = appGroupFolder ?? searchPathFolder
        let logsIdentifier = identifier + ".logs"
        let logsFolder = used.appendingPathComponent(logsIdentifier)

        createFolder(logsFolder)

        return logsFolder
    }()
    private let fileTime: FileTime
    private let identifier: String

    public convenience init(appGroup: String, identifier: String = Bundle.main.bundleIdentifier!, name: String? = nil, fileTime: FileTime = .minuteBased, keep: Keep = .forever) {
        self.init(appGroup: appGroup, directory: .documentDirectory, identifier: identifier, name: name, fileTime: fileTime, keep: keep)
    }
    
    public convenience init(saveInDirectory: FileManager.SearchPathDirectory = .documentDirectory, identifier: String = Bundle.main.bundleIdentifier!, name: String? = nil, fileTime: FileTime = .minuteBased, keep: Keep = .forever) {
        self.init(appGroup: nil, directory: saveInDirectory, identifier: identifier, name: name, fileTime: fileTime, keep: keep)
    }
    
    private init(appGroup: String?, directory: FileManager.SearchPathDirectory, identifier: String, name: String?, fileTime: FileTime = .minuteBased, keep: Keep) {
        self.appGroup = appGroup
        saveInDirectory = directory
        self.identifier = identifier
        proposedName = name
        self.fileTime = fileTime
        DispatchQueue.global(qos: .utility).async {
            self.cleanOld(with: keep)
        }
    }
    
    open func printMessage(_ message: String) {
        let written = "\(message)\n"
        let data = written.data(using: .utf8) ?? "<- No UTF8 data ->\n".data(using: .utf8)
        if let handle = handle(), let write = data {
            handle.write(write)
        }
    }
    
    private func handle() -> FileHandle? {
        if let handle = fileHandle {
            return handle
        }

        let fileName: String
        if let proposed = proposedName {
            fileName = proposed
        } else {
            let time = dateFormatter.string(from: Date())
            fileName = "\(appNamePrefix)\(time).txt"
        }
        let fileURL = logsFolder.appendingPathComponent(fileName)
        
        makeSureFileExists(fileURL)
        
        do {
            let opened: FileHandle = try FileHandle(forWritingTo: fileURL)
            opened.seekToEndOfFile()
            fileHandle = opened
                
            return fileHandle
        } catch let error as NSError {
            print("\(error)")
            
            return nil
        }
    }

    private func createFolder(_ path: URL) {
        if FileManager.default.fileExists(atPath: path.path) {
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Create logs folder error \(error)")
        }
    }
    
    private func makeSureFileExists(_ atURL: URL) {
        if FileManager.default.fileExists(atPath: atURL.path) {
            return
        }
        
        try? Data().write(to: atURL, options: [.atomic])
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        switch fileTime {
        case .dateBased:
            formatter.dateFormat = "yyyy-MM-dd"
        case .minuteBased:
            formatter.dateFormat = "yyyy-MM-dd-HH-mm"
        }
        return formatter
    }()
    
    private func cleanOld(with keep: Keep) {
        if keep == .forever {
            Log.logger.debug("Keeping all files")
            return
        }
        
        let files = listLogFiles()
        Log.logger.debug("Have \(files.count) log files")
        switch keep {
        case .forever: break
        case .days(let days):
            Log.logger.debug("Removing older than \(days) days")
            guard let after = Calendar(identifier: .gregorian).date(byAdding: .day, value: -days, to: Date()) else {
                return
            }
            let removed = files.filter({ $0.creationDate! < after })
            remove(files: removed)
        case .number(let number):
            Log.logger.debug("Keep \(number) latest files")
            guard files.count > number else {
                return
            }
            
            let suffix = Array(files.suffix(from: number))
            remove(files: suffix)
        }
    }
    
    private func remove(files: [LogFile]) {
        Log.debug("Will remove \(files.count) files")
        for file in files {
            DispatchQueue.global(qos: .utility).async {
                try? FileManager.default.removeItem(at: file.file)
            }
        }
    }
    
    
    public func listLogFiles() -> [LogFile] {
        var withDate = [LogFile]()
        do {
            let paths = try FileManager.default.contentsOfDirectory(at: logsFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            for path in paths {
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: path.path)
                    if let date = attr[FileAttributeKey.creationDate] as? Date {
                        withDate.append(LogFile(file: path, creationDate: date))
                    }
                } catch {
                    Log.logger.error("List attributes error: \(error)")
                }
            }
        } catch {
            Log.logger.error("List log files error: \(error)")
        }
        
        return withDate.sorted(by: { $0.creationDate! > $1.creationDate! })
    }
}

public struct LogFile {
    public let name: String
    public let file: URL
    let creationDate: Date?
}

extension LogFile {
    internal init(file: URL, creationDate: Date) {
        name = file.lastPathComponent
        self.file = file
        self.creationDate = creationDate
    }
    
    internal init(name: String, path: URL) {
        self.name = name
        self.file = path
        creationDate = nil
    }
}
