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

import UIKit

public class AdPresentingContainerViewController: UIViewController {
    @IBOutlet private var adsContainer: UIView!
    @IBOutlet private var adsContainerHeight: NSLayoutConstraint!
    public var mediator: AdsMediator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        adsContainerHeight.constant = 0
        adsContainer.clipsToBounds = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard var med = mediator else {
            Logging.log("No ad mediator provided")
            return
        }
        
        if med.revealHandler == nil {
            med.revealHandler = {
                [unowned self] action in
                
                switch action {
                case .show:
                    self.show()
                case .hide:
                    self.hide()
                }
            }
        }
        
        
        loadBanner()
    }
    
    private func loadBanner() {
        Logging.log("Load banner")
        guard var med = mediator else {
            return
        }

        med.loadBanner(on: self) {
            loaded in
            
            self.adsContainer.addSubview(loaded)
        }
    }
    
    private func show() {
        Logging.log("Show banner")
        guard let banner = adsContainer.subviews.first else {
            return
        }
        
        if banner.frame.height == adsContainerHeight.constant {
            return
        }
        
        banner.center = CGPoint(x: adsContainer.frame.midX, y: adsContainer.frame.midY)
        banner.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin]
        UIView.animate(withDuration: 0.3) {
            self.adsContainerHeight.constant = banner.frame.height
        }
    }
    
    private func hide() {
        Logging.log("Hide banner")
        guard adsContainerHeight.constant > 0.1 else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.adsContainerHeight.constant = 0
        }
    }
}
