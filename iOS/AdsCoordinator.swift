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

import SpriteKit

private let AdPresentationHeightInTiles = 5
private let ShowEveryXLine = 40
private let PresentedSectionHeight = AdPresentationHeightInTiles + ShowEveryXLine

class AdsCoordinator {
    var tileSize = CGSize.zero {
        didSet {
            for (_, view) in presented {
                view.removeFromSuperview()
            }
            
            presented.removeAll()
        }
    }
    var presentIn: UIView?
    var totalLines: Int = 0
    private var presented: [Int: UIView] = [:]
    
    func combinedHeight(with lines: Int) -> Int {
        let adsToShow = Int(lines / ShowEveryXLine)
        return adsToShow * Int(tileSize.height) * AdPresentationHeightInTiles
    }
    
    func offsetFor(index: Int) -> Int {
        let line = Int(index / NumberOfColumns)
        let adsBefore = Int(line / ShowEveryXLine)
        return adsBefore * AdPresentationHeightInTiles * Int(tileSize.height)
    }
    
    func removeAdLines(_ lines: Int) -> Int {
        let numberOfSections = Int(lines / PresentedSectionHeight)
        
        if numberOfSections == 0 {
            return lines
        }
        
        let reminder = lines % PresentedSectionHeight
        return numberOfSections * ShowEveryXLine + reminder
    }
    
    func adLines(for tileLines: Int) -> Int {
        return Int(tileLines / ShowEveryXLine) * AdPresentationHeightInTiles
    }
    
    func scrolled(to visible: CGRect) {
        guard tileSize != .zero else {
            return
        }
        
        guard totalLines > ShowEveryXLine else {
            return
        }
        
        guard let view = presentIn else {
            return
        }
        
        var inViewSpace = visible
        inViewSpace.origin.y = view.frame.height - visible.origin.y - visible.height
        
        let topOnLine = Int(inViewSpace.origin.y / tileSize.height)
        var adLine = max(topOnLine - (topOnLine % PresentedSectionHeight) - AdPresentationHeightInTiles, ShowEveryXLine)
        
        let adHeight = CGFloat(AdPresentationHeightInTiles) * tileSize.height
        while true {
            defer {
                adLine += PresentedSectionHeight
            }
            
            let checkedY = CGFloat(adLine) * tileSize.height
            if checkedY > inViewSpace.origin.y + inViewSpace.size.height {
                break
            }
            
            if let _ = presented[adLine] {
                continue
            }
            
            let renderView = AdRenderView()
            
            renderView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(renderView)
            presented[adLine] = renderView
            
            let top = NSLayoutConstraint(item: renderView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: checkedY)
            let width = NSLayoutConstraint(item: renderView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
            let height = NSLayoutConstraint(item: renderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: adHeight)
            let centered = NSLayoutConstraint(item: renderView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            view.addConstraints([top, width, height, centered])
        }
    }
        
    private func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    func hide() {
        for (_, view) in presented {
            view.isHidden = true
        }
    }
    
    func show() {
        for (_, view) in presented {
            view.isHidden = false
        }
    }
}
