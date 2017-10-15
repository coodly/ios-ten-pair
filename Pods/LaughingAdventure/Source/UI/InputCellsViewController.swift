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

import UIKit

private extension Selector {
    static let contentSizeChanged = #selector(InputCellsViewController.contentSizeChanged)
    
    #if os(iOS)
    static let willAppear = #selector(InputCellsViewController.keyboardWillAppear(notification:))
    static let willDisappear = #selector(InputCellsViewController.keyboardWillDisappear(notification:))
    #endif
}

public class InputCellsSection {
    fileprivate let cells: [UITableViewCell]
    fileprivate var title: String?
    fileprivate var header: UIView?
    
    public init(header: UIView, cells: [UITableViewCell]) {
        self.header = header
        self.cells = cells
    }
    
    public init(title: String? = nil, cells: [UITableViewCell]) {
        self.title = title
        self.cells = cells
    }
    
    func numberOfCells() -> Int {
        return cells.count
    }
    
    func cellAtRow(_ row: Int) -> UITableViewCell {
        return cells[row]
    }
}

open class InputCellsViewController: UIViewController, FullScreenTableCreate, SmoothTableRowDeselection {
    public var tableTop: NSLayoutConstraint?

    @IBOutlet public var tableView: UITableView!
    fileprivate var sections: [InputCellsSection] = []
    fileprivate var activeCellInputValidation: InputValidation?
    open var preferredStyle: UITableViewStyle {
        return .plain
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidLoad() {
        checkTableView(preferredStyle)
        
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: .willAppear, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .willDisappear, name: Notification.Name.UIKeyboardWillHide, object: nil)
        #endif
        NotificationCenter.default.addObserver(self, selector: .contentSizeChanged, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 20
        
        tableView.tableFooterView = UIView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        smoothDeselectRows()
        
        configureReturnButtons()
    }
    
    fileprivate func handleCellTap(_ cell: UITableViewCell, atIndexPath:IndexPath) -> Bool {
        if cell.isKind(of: TextEntryCell.self) {
            let entryCell = cell as! TextEntryCell
            entryCell.entryField.becomeFirstResponder()
            return false
        } else {
            return tapped(cell: cell, at: atIndexPath)
        }
    }
    
    open func tapped(cell: UITableViewCell, at indexPath: IndexPath) -> Bool {
        Logging.log("tappedCell")
        return false
    }
    
    public func addSection(_ section: InputCellsSection) {
        sections.append(section)
        for cell in section.cells {
            if let textCell = cell as? TextEntryCell {
                textCell.entryField.delegate = self
            } else if let multi = cell as? MultiEntryCell {
                for field in multi.entryFields {
                    field.delegate = self
                }
            }
            
        }
    }
    
    fileprivate func indexPathForCell(_ cell: UITableViewCell) -> IndexPath? {
        for section in 0 ..< sections.count {
            let sec = sections[section]
            
            if let row = sec.cells.index(of: cell) {
                return IndexPath(row: row, section: section)
            }
        }
        
        return nil
    }
    
    fileprivate func nextEntryCellAfterIndexPath(_ indexPath: IndexPath) -> UITableViewCell? {
        let section = indexPath.section
        var row = indexPath.row + 1
        
        let sectionRange = section..<sections.count
        
        for section in sectionRange {
            let sec = sections[section]
            
            let rowRange = row..<sec.cells.count
            
            for row in rowRange {
                let checked = sec.cells[row]
                if checked is TextEntryCell || checked is MultiEntryCell {
                    return checked
                }
            }
            
            row = 0
        }
        
        return nil
    }
    
    @objc fileprivate func contentSizeChanged() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func configureReturnButtons() {
        var lastEntryCell: TextEntryCell?
        for section in sections {
            for cell in section.cells {
                guard let textEntry = cell as? TextEntryCell else {
                    continue
                }
                
                textEntry.setReturnKeyType(.next)
                lastEntryCell = textEntry
            }
        }
        
        if let last = lastEntryCell {
            last.setReturnKeyType(.done)
        }
    }
}

// MARK: - Sections / cells
public extension InputCellsViewController {
    func replaceCell(atIndexPath indexPath: IndexPath, withCell cell: UITableViewCell) {
        if let textEntryCell = cell as? TextEntryCell {
            textEntryCell.entryField.delegate = self
        }
        
        tableView.beginUpdates()
        
        let section = sections[(indexPath as NSIndexPath).section]
        var cells = section.cells
        cells[(indexPath as NSIndexPath).row] = cell
        sections[(indexPath as NSIndexPath).section] = InputCellsSection(cells: cells)
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        tableView.endUpdates()

        configureReturnButtons()
    }
}

// MARK: - Table view delegates
extension InputCellsViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCells = sections[section]
        return sectionCells.numberOfCells()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionCells = sections[(indexPath as NSIndexPath).section]
        return sectionCells.cellAtRow((indexPath as NSIndexPath).row)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[(indexPath as NSIndexPath).section]
        let cell = section.cellAtRow((indexPath as NSIndexPath).row)
        let detailsShonw = handleCellTap(cell, atIndexPath: indexPath)
        
        if detailsShonw {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = sections[section].title {
            return UITableViewAutomaticDimension
        }
        
        if let _ = sections[section].header {
            return UITableViewAutomaticDimension
        }
        
        return 0
    }
}

// MARK: - Text field delegate
extension InputCellsViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeCellInputValidation = (textField.findContainingCell() as? EntryValidated)?.validator(for: textField)
        
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let validation = activeCellInputValidation else {
            return true
        }
        
        return validation.textField(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var resign = false
        defer {
            if resign {
                textField.resignFirstResponder()
                entryComplete()
            }
        }
        
        if let cell = textField.findContainingCell() as? MultiEntryCell, let nextField = cell.nextEntry(after: textField) {
            activeCellInputValidation = cell.validator(for: nextField)
            nextField.becomeFirstResponder()
            return true
        }
        
        guard let cell = textField.findContainingCell(), cell is TextEntryCell || cell is MultiEntryCell else {
            resign = true
            return true
        }
        
        guard let indexPath = indexPathForCell(cell), let nextCell = nextEntryCellAfterIndexPath(indexPath) else {
            resign = true
            return true
        }
        
        if let multiCell = nextCell as? MultiEntryCell, let field = multiCell.firstField() {
            activeCellInputValidation = multiCell.validator(for: field)
            field.becomeFirstResponder()
        } else if let entry = nextCell as? TextEntryCell {
            entry.entryField.becomeFirstResponder()
            activeCellInputValidation = entry.validator(for: entry.entryField)
        } else {
            resign = true
        }
        
        return true
    }
    
    open func entryComplete() {
        Logging.log("Entry complete")
    }
}

#if os(iOS)
extension InputCellsViewController {
    @objc fileprivate func keyboardWillAppear(notification: Notification) {
        guard let info = notification.userInfo, let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: 0.3)
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
    }
    
    @objc fileprivate func keyboardWillDisappear(notification: Notification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: 0.3)
        
        tableView.contentInset = UIEdgeInsets.zero
    }
}
#endif
