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

private extension Selector {
    static let scrolled = #selector(ScrollView.didScroll(notification:))
}

public class ScrollView: View {
    override var backingView: PlatformView {
        return scrollView
    }
    internal var contained: ScrollViewContained?
    internal var contentOffsetY: CGFloat {
        return scrollView.contentView.visibleRect.origin.y
    }
    private lazy var scrollView: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.drawsBackground = false
        view.hasVerticalScroller = true
        view.automaticallyAdjustsContentInsets = false
        
        NotificationCenter.default.addObserver(self, selector: .scrolled, name: NSNotification.Name.NSScrollViewDidLiveScroll, object: nil)
        
        return view
    }()
    fileprivate lazy var dummy: NSView = {
        var dummy = Flipper(frame: .zero)
        dummy.wantsLayer = true
        self.scrollView.documentView = dummy
        return dummy
    }()
    internal var contentSize: CGSize = .zero {
        didSet {
            dummy.frame = CGRect(x: 0, y: 0, width: self.size.width, height: contentSize.height)
        }
    }
    public var contentInset: EdgeInsets = NSEdgeInsetsZero
    
    @objc fileprivate func didScroll(notification: NSNotification) {
        guard let object = notification.object as? NSScrollView, scrollView === object else {
            return
        }
        
        positionPresentedNode()
    }
    
    override func sizeChanged() {
        super.sizeChanged()
        
        positionPresentedNode()
    }
}

private class Flipper: NSView {
    override var isFlipped: Bool {
        return true
    }
}
