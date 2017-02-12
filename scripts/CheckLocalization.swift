/*
 * Copyright 2017 Coodly LLC
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
import QuartzCore

extension String {
    func isSortMarker() -> Bool {
        return hasPrefix("/**") && hasSuffix("**/")
    }
    
    func isMergeConflictMarker() -> Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).range(of: "<<<<<<") != nil
    }
    
    func hasSamePrefix(_ other: String) -> Bool {
        let prefix = commonPrefix(with: other)
        return prefix.range(of: ".") != nil
    }
}

class Language {
    let code: String
    let path: URL
    
    private var lines: [String]!
    private var hadSortMarker = false
    
    init(code: String, path: URL) {
        self.code = code
        self.path = path
    }
    
    func load() -> Bool {
        var lines = [String]()
        let content = try! String(contentsOf: path, encoding: .utf8)
        var haveMergeConflict = false
        content.enumerateLines() {
            line, cont in
            
            if line.isMergeConflictMarker() {
                cont = false
                haveMergeConflict = true
                return
            }
            
            lines.append(line)
            self.hadSortMarker = self.hadSortMarker || line.isSortMarker()
        }
        
        self.lines = lines
        print("Loaded \(lines.count) lines")
        if hadSortMarker {
            print("Had sort marker")
        }
        
        return !haveMergeConflict
    }
    
    func write() {
        let unsorted: [String]
        var sorted: [String]
        if let splitIndex = lines.index(where: { $0.isSortMarker() }) {
            unsorted = Array(lines.prefix(upTo: 0.distance(to: splitIndex) + 1))
            sorted = Array(lines.suffix(from: 0.distance(to: splitIndex) + 1))
        } else {
            unsorted = []
            sorted = lines
        }

        var content = unsorted.joined(separator: "\n")
        if hadSortMarker {
            content.append("\n")
        }
        
        sorted.sort()
        
        var last = ""
        for line in sorted {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                continue
            }
            
            if !last.hasSamePrefix(line) && !content.isEmpty {
                content.append("\n")
            }

            content.append(line)
            content.append("\n")
            
            last = line
        }
        
        let data = content.data(using: .utf8)!
        try! data.write(to: path)
    }
}

class Checker {
    private let input: URL
    init(input: URL) {
        self.input = input
    }
    
    func execute() {
        let start = CACurrentMediaTime()
        print("Check files at \(input)")
        
        guard isFolder(input.path) else {
            print("Invalid path: \(input)")
            return
        }
        
        let files = try! FileManager.default.contentsOfDirectory(atPath: input.path)
        var languages = [Language]()
        for f in files {
            guard f.hasSuffix(".lproj") else {
                continue
            }
            
            let fullPath = input.appendingPathComponent(f, isDirectory: true)
            guard isFolder(fullPath.path) else {
                continue
            }
            
            let localizable = fullPath.appendingPathComponent("Localizable.strings", isDirectory: false)
            guard FileManager.default.fileExists(atPath: localizable.path) else {
                continue
            }
            
            let indexOfSuffix = f.range(of: ".lproj")!.lowerBound
            let code = f.substring(to: f.index(indexOfSuffix, offsetBy: 0))
            let language = Language(code: code, path: localizable)
            languages.append(language)
        }
        
        print("Found \(languages.count) languages: \(languages.map({ $0.code }))")
        
        for l in languages {
            guard l.load() else {
                print("warning: Have merge conflicts. Abort")
                exit(1)
            }
        }
        
        for l in languages {
            l.write()
        }
        
        print(String(format: "Execution time: %f", CACurrentMediaTime() - start))
    }
    
    private func isFolder(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: input.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }
}

guard CommandLine.arguments.count == 2 else {
    print("Usage: CheckLocalization <path_to_languages_folder>")
    exit(1)
}

let folder = CommandLine.arguments.last!
let inputFolder = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(folder, isDirectory: true)

let check = Checker(input: inputFolder)
check.execute()
