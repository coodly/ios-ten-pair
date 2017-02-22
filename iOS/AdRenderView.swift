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

import UIKit
import GoogleMobileAds

class AdRenderView: UIView, GADNativeExpressAdViewDelegate {
    private static var adView: GADNativeExpressAdView = {
        let gadView = GADNativeExpressAdView(adSize: GADAdSizeFromCGSize(CGSize(width: 320, height: 240)))!
        gadView.adUnitID = AdMobAdUnitID
        //gadView.delegate = self
        // |-(
        gadView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        gadView.load(request)
        gadView.translatesAutoresizingMaskIntoConstraints = false
        return gadView
    }()
    private lazy var clipView: UIView = {
        let clip = UIView()
        clip.backgroundColor = .clear
        clip.clipsToBounds = true
        
        self.clipTop = NSLayoutConstraint(item: clip, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: clip, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: clip, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: clip, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        clip.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(clip)
        
        self.addConstraints([self.clipTop!, leading, trailing, bottom])
        
        return clip
    }()
    private var clipTop: NSLayoutConstraint?
    private var adLeading: NSLayoutConstraint?
    
    private var scroll: UIScrollView?
    private var meInScroll: CGRect {
        guard let scroll = scroll, let container = superview else {
            return .zero
        }
        return  scroll.convert(frame, from: container)
    }
    private var visibleScroll: CGRect {
        guard let scroll = scroll else {
            return .zero
        }
        
        var visibleScroll = scroll.bounds
        visibleScroll.origin.y = scroll.contentOffset.y
        
        return visibleScroll
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        AdRenderView.adView.delegate = self
        scroll = superview?.superview as? UIScrollView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard isVisible() else {
            return
        }
        
        let topMenu = CGRect(x: 0, y: scroll!.contentOffset.y, width: scroll!.frame.width, height: TopMenuBarHeight)
        let topInMe = convert(topMenu, from: scroll!)
        if topInMe.maxY > 0 {
            clipView.clipsToBounds = true
            clipTop?.constant = topInMe.maxY
        } else {
            clipView.clipsToBounds = false
            clipTop?.constant = 0
        }
        
        let hint = CGRect(x: 0, y: scroll!.contentOffset.y + scroll!.frame.height - 10 - ActionButtonsTrayHeight, width: ActionButtonsTrayHeight, height: ActionButtonsTrayHeight)
        let hintInMe = convert(hint, from: scroll!)
        let intersection = bounds.intersection(hintInMe)
        adLeading?.constant = intersection.width
        
        guard clipView.subviews.count == 0 else {
            return
        }
        
        
        let adView = AdRenderView.adView
        
        let height = NSLayoutConstraint(item: adView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        adLeading = NSLayoutConstraint(item: adView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: adView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: adView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        clipView.addSubview(adView)
        addConstraints([height, adLeading!, width, bottom])
    }
    
    private func isVisible() -> Bool {
        return meInScroll.intersects(visibleScroll)
    }
    
    public func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        Log.debug("Did receive ad")
    }
    
    public func nativeExpressAdView(_ nativeExpressAdView: GADNativeExpressAdView, didFailToReceiveAdWithError error: GADRequestError) {
        Log.debug("Failed to receive ad: \(error)")
    }
}
