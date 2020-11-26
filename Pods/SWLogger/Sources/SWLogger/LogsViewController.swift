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

#if os(iOS)
import UIKit

private extension Selector {
    static let dismiss = #selector(LogsViewController.dismissLogsController)
}

public class LogsViewController: UITableViewController {
    fileprivate var files = [LogFile]()
    
    public var includeFilesFrom: FileOutput?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .dismiss)
    }
    
    @objc fileprivate func dismissLogsController() {
        self.dismiss(animated: true)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listFiles()
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "reuseIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        let file = files[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = file.name
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let file = files[(indexPath as NSIndexPath).row]
        
        let activityController = UIActivityViewController(activityItems: [file.file], applicationActivities: nil)
        
        let rect = tableView.rectForRow(at: indexPath)
        activityController.popoverPresentationController?.sourceView = tableView
        activityController.popoverPresentationController?.sourceRect = rect
        
        present(activityController, animated: true, completion: nil)
    }
}

private extension LogsViewController {
    func listFiles() {
        var files = [LogFile]()
        for output in Logger.sharedInstance.outputs {
            guard let fileOutput = output as? FileOutput else {
                continue
            }
            
            files.append(contentsOf: listFiles(for: fileOutput))
        }
        if let output = includeFilesFrom {
            files.append(contentsOf: listFiles(for: output))
        }

        self.files = files.sorted(by: { (left, right) -> Bool in
            return left.name.compare(right.name) == .orderedDescending
        })
    }
    
    private func listFiles(for output: FileOutput) -> [LogFile] {
        var logFiles = [LogFile]()
        do {
            let files = try FileManager.default.contentsOfDirectory(at: output.logsFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]).reversed()
            
            for file in files {
                let logFile = LogFile(name: file.lastPathComponent, path: file)
                logFiles.append(logFile)
            }
        } catch let error as NSError {
            Log.error(error)
        }
        
        return logFiles
    }
}
#endif
