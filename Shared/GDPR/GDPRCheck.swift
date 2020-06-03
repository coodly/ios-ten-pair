//
//  GDPRCheck.swift
//  iOS
//
//  Created by Jaanus Siim on 03.06.2020.
//  Copyright © 2020 Coodly LLC. All rights reserved.
//

import Foundation

public protocol GDPRCheck {
    var showGDPRConsentMenuItem: Bool { get }
    var canShowPersonalizedAds: Bool { get }
    
    func check()
}
