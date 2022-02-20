import Autolayout
import ComposableArchitecture
import GameplayKit
import LoadingPresentation
import MenuPresentation
import Play
import PlayFeature
import PlaySummaryFeature
import RandomLines
import Save
import Storyboards
import SwiftUI
import UIComponents
import UIKit
import WinPresentation

internal protocol PlayDelegate: AnyObject {
    func animateFailure()
    func animateSuccess()
    func clearSelection()
    func checkEmptyLines()
    func checkGameEnd()
}

public class PlayViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "Play"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    public var store: Store<PlayFeature.PlayState, PlayAction>!
    
    private lazy var summaryStore = store.scope(state: \.playSummaryState, action: PlayAction.playSummary)
    private lazy var summaryView = PlaySummaryView(store: summaryStore)
    private lazy var summaryHosting = UIHostingController(rootView: summaryView)
    
    private lazy var imageConfig = UIImage.SymbolConfiguration(weight: .heavy)
    private lazy var menuImage = UIImage(systemName: "line.horizontal.3.decrease.circle", withConfiguration: imageConfig)
    private lazy var menuButton = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(presentMenu))
    private lazy var reloadImage = UIImage(systemName: "arrow.2.circlepath", withConfiguration: imageConfig)
    private lazy var reloadButton = UIBarButtonItem(image: reloadImage, style: .plain, target: self, action: #selector(reloadField))
    
    private lazy var field = PlayField(save: FieldSave.active, random: GKMersenneTwisterRandomSource())
    
    @IBOutlet private var collectionView: UICollectionView!
    private var selected = Set<Int>()
    
    private lazy var machine = GKStateMachine(states: [
        SelectingNumber(delegate: self),
        AnimatingSuccess(delegate: self),
        AnimatingFailure(delegate: self),
        EmptyLinesCheck(delegate: self),
        CheckGameEnd(delegate: self)
    ])
    @IBOutlet private var hintButton: UIButton!
    @IBOutlet private var undoButton: UIButton!
    @IBOutlet private var undoTray: UIView!
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var layout = NumbersFlowLayout()
    private lazy var layoutPosition = layout.layoutPosition

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = summaryHosting.view
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = reloadButton
        [menuButton, reloadButton]
            .forEach({
                $0.setTitleTextAttributes(
                    [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], for: .normal)
            })
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundView = BackgroundView()
        
        field.load()
        
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = reloadButton
        NumberCell.register(in: collectionView)
        AdPresentingCell.register(in: collectionView)
        
        machine.enter(SelectingNumber.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveField), name: UIApplication.willResignActiveNotification, object: nil)
        
        hintButton.setImage(UIImage(systemName: "lightbulb.fill", withConfiguration: imageConfig), for: .normal)
        undoButton.setImage(UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfig), for: .normal)
        
        undoTray.isHidden = true
        undoManager?.levelsOfUndo = 10
    }

    @objc fileprivate func reloadField() {
        guard machine.currentState is SelectingNumber else {
            return
        }
        
        undoManager?.removeAllActions()
        updateUndoVisibility()
        performWithLoading() {
            callback in

            DispatchQueue.global(qos: .background).async {
                self.field.reload()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    callback()
                }
            }
        }
        
        NotificationCenter.default.post(name: .fieldReload, object: nil)
    }
    
    @objc fileprivate func saveField() {
        field.save()
    }
    
    @IBAction private func giveAHint() {
        guard let hintIndex = field.openMatch()?.first else {
            collectionView.shake()
            return
        }

        NotificationCenter.default.post(name: .hintTaken, object: nil)

        performWithLoading() {
            callback in
            
            let original = self.selected
            self.selected.removeAll()
            self.selected.insert(hintIndex)
            let index = IndexPath(row: hintIndex, section: 0)
            if self.collectionView.indexPathsForVisibleItems.contains(index) {
                self.reload(previous: original, current: self.selected, animated: false)
            }
            self.collectionView.scrollToItem(at: index, at: .centeredVertically, animated: false)
            callback()
        }
    }
    
    @IBAction private func performUndo() {
        undoManager?.undo()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func reload(indexes: Set<Int>, completion: ((Bool) -> Void)? = nil) {
        reload(previous: indexes, current: indexes, animated: true, completion: completion)
    }
    
    private func reload(previous: Set<Int>, current: Set<Int>, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let reloaded = previous.union(current)
        let indexPaths = reloaded.map({ IndexPath(row: $0, section: 0) })
        
        let animation: (() -> Void) = {
            let updates: (() -> Void) = {
                self.collectionView.reloadItems(at: indexPaths)
            }
            self.collectionView.performBatchUpdates(updates, completion: completion)
        }
        
        if animated {
            animation()
        } else {
            UIView.performWithoutAnimation(animation)
        }
    }
    
    private func checkForMatch() {
        guard selected.count > 1 else {
            return
        }
        
        let array = Array(selected)
        guard let first = array.first, let second = array.last else {
            return
        }
        
        let action = field.match(first: first, second: second)
        switch action {
        case .failure:
            machine.enter(AnimatingFailure.self)
        case .match:
            machine.enter(AnimatingSuccess.self)
        }
    }
    
    @objc fileprivate func presentMenu() {
        let menu = MenuUIViewController.instance
        menu.delegate = self
        menu.gameWon = field.gameEnded
        
        menu.modalPresentationStyle = .custom
        
        presentModal(menu)
    }
    
    private typealias Callback = (() -> Void)
    private func performWithLoading(closure: @escaping ((@escaping Callback) -> Void)) {
        let loading = LoadingViewController.instance
        loading.modalPresentationStyle = .custom
        let dismiss: Callback = {
            [weak self] in
            
            self?.dismissModal()
        }
        presentModal(loading) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                closure(dismiss)
            }
        }
    }
    
    private func presentModal(_ controller: UIViewController, completion: (() -> Void)? = nil) {
        navigationController?.addChild(controller)
        navigationController?.view.addSubview(controller.view)
        controller.view.pinToSuperviewEdges()
        controller.viewWillAppear(false)
        completion?()
    }
    
    private func dismissModal() {
        navigationController?.children.filter({ $0 != self }).forEach() {
            controller in
            
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
    }
}

extension PlayViewController {
    private func register(removed: [Position]) {
        undoManager?.beginUndoGrouping()
        self.undoManager?.registerUndo(withTarget: self) {
            selfTarget in
            
            selfTarget.restore(positions: removed)
            DispatchQueue.main.async(execute: selfTarget.updateUndoVisibility)
        }
        let possiblyRemoved = field.emptyLines(with: Set(removed.map({ $0.index })))
        if possiblyRemoved.count > 0 {
            let linePositions = possiblyRemoved.flatMap({ $0.map({ Position(index: $0, value: 0) }) })
            register(lines: linePositions)
        }

        undoManager?.endUndoGrouping()
        updateUndoVisibility()
    }
    
    private func register(lines: [Position]) {
        undoManager?.registerUndo(withTarget: self) {
            selfTarget in
            
            self.restore(lines: lines)
        }
    }
    
    private func restore(lines: [Position]) {
        queue.addOperation(ScrollOperation(collection: collectionView, positions: lines))
        queue.addOperation(RestoreRows(collection: collectionView, positions: lines, field: field))
    }
    
    private func restore(positions: [Position]) {
        queue.addOperation(ScrollOperation(collection: collectionView, positions: positions))
        queue.addOperation(RestoreNumbers(collection: collectionView, positions: positions, field: field))
    }
    
    private func updateUndoVisibility() {
        undoTray.isHidden = !(undoManager?.canUndo ?? false)
    }
}

extension PlayViewController: PlayDelegate {
    func animateSuccess() {
        reload(indexes: selected) {
            _ in
            
            let positions = self.field.clear(numbers: self.selected)
            self.machine.enter(EmptyLinesCheck.self)
            self.register(removed: positions)
        }
    }
    
    func animateFailure() {
        reload(indexes: selected) {
            _ in
            
            self.machine.enter(SelectingNumber.self)
        }
    }
    
    func clearSelection() {
        guard selected.count > 0 else {
            return
        }
        
        let animated = selected
        selected.removeAll()
        reload(indexes: animated)
    }
    
    func checkEmptyLines() {
        let animated = selected
        selected.removeAll()
        reload(indexes: animated) {
            _ in
            
            self.removeEmptyLines(checked: animated)
        }
    }
    
    private func removeEmptyLines(checked: Set<Int>) {
        let empty = field.emptyLines(with: checked)
        guard empty.count > 0 else {
            machine.enter(CheckGameEnd.self)
            return
        }
        
        field.remove(lines: empty)
        let removed = empty.map({ Array($0.lowerBound..<$0.upperBound) }).flatMap({ $0 }).map({ IndexPath(row: $0, section: 0) })
        let update: (() -> Void) = {
            self.collectionView.deleteItems(at: removed)
        }
        collectionView.performBatchUpdates(update) {
            _ in
            
            self.machine.enter(CheckGameEnd.self)
        }
    }
    
    func checkGameEnd() {
        if field.gameEnded {
            undoManager?.removeAllActions()
            updateUndoVisibility()
            presentWin()
        }
        
        machine.enter(SelectingNumber.self)
    }
    
    private func presentWin() {
        let win = WinViewController.instance
        win.modalPresentationStyle = .custom
        presentModal(win)
    }
}

extension PlayViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        layoutPosition.numberOfSections(with: field.numbers)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        layoutPosition.numberOfRows(in: section, using: field.numbers)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section % 2 == 1 {
            return collectionView.dequeueReusableCell(for: indexPath) as AdPresentingCell
        }
        
        let cell: NumberCell = collectionView.dequeueReusableCell(for: indexPath)
        let marker: NumberMarker
        if selected.contains(indexPath.row) {
            marker = NumberMarker.from(state: machine.currentState as? PlayState)
        } else {
            marker = .standard
        }
        cell.show(number: field.number(at: indexPath.row), marker: marker)
        return cell
    }
}

extension PlayViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard machine.currentState is SelectingNumber else {
            return false
        }
        
        return field.hasValue(at: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let original = selected
        if selected.contains(indexPath.row) {
            selected.remove(indexPath.row)
        } else {
            selected.insert(indexPath.row)
        }
        
        reload(previous: original, current: selected, animated: false) {
            _ in
            
            self.checkForMatch()
        }
    }
}

extension PlayViewController: MenuUIDelegate {
    public func restart(_ lines: Int) {
        dismissModal()
        
        selected.removeAll()
        collectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: false)
        
        if lines == 0 {
            field.restartRegular()
            collectionView.reloadData()
            return
        }
        
        performWithLoading() {
            completion in
            
            DispatchQueue.global(qos: .background).async {
                let numbers = RandomLines.active.generate(lines)
                
                DispatchQueue.main.async {
                    self.field.restart(tiles: numbers)
                    self.collectionView.reloadData()
                    completion()
                }
            }
        }
    }
    
    public func dismissMenu() {
        dismissModal()
    }
}

private class UIOperation: ConcurrentOperation {
    final override func main() {
        DispatchQueue.main.async(execute: performOnMain)
    }
    
    func performOnMain() {
        fatalError()
    }
}

private class ScrollOperation: UIOperation {
    private let collection: UICollectionView!
    private let index: Int
    init(collection: UICollectionView, positions: [Position]) {
        self.collection = collection
        self.index = positions.map({ $0.index }).min() ?? 0
    }
    
    override func performOnMain() {
        let scrollTo = IndexPath(row: index, section: 0)
        if collection.indexPathsForVisibleItems.contains(scrollTo) {
            self.finish()
            return
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.finish()
            }
        }
        collection.scrollToItem(at: scrollTo, at: .centeredVertically, animated: true)
        CATransaction.commit()
    }
}

private class RestoreRows: UIOperation {
    private let collection: UICollectionView
    private let positions: [Position]
    private let field: PlayField
    init(collection: UICollectionView, positions: [Position], field: PlayField) {
        self.collection = collection
        self.positions = positions
        self.field = field
    }
    
    override func performOnMain() {
        field.insert(positions: positions)
        let insert: (() -> Void) = {
            self.collection.insertItems(at: self.positions.map({ IndexPath(row: $0.index, section: 0) }))
        }
        collection.performBatchUpdates(insert) {
            _ in
            
            self.finish()
        }
    }
}

private class RestoreNumbers: UIOperation {
    private let collection: UICollectionView
    private let positions: [Position]
    private let field: PlayField
    init(collection: UICollectionView, positions: [Position], field: PlayField) {
        self.collection = collection
        self.positions = positions
        self.field = field
    }
    
    override func performOnMain() {
        field.restore(positions: positions)
        let insert: (() -> Void) = {
            self.collection.reloadItems(at: self.positions.map({ IndexPath(row: $0.index, section: 0) }))
        }
        collection.performBatchUpdates(insert) {
            _ in
            
            self.finish()
        }
    }
}

extension NumberMarker {
    fileprivate static func from(state: PlayState?) -> NumberMarker {
        switch state {
        case is SelectingNumber:
            return .selection
        case is AnimatingSuccess:
            return .success
        case is AnimatingFailure:
            return .failure
        default:
            fatalError()
        }
    }
}
