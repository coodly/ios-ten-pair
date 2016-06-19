//
//  Constants.swift
//  TenPair
//
//  Created by Jaanus Siim on 12/06/16.
//  Copyright © 2016 Coodly LLC. All rights reserved.
//

import Foundation

let NumberOfColumns = 9
let TenPairSaveDataKey = "NumbersGameSaveDataKey"
let FullVersionIdentifier = "com.coodly.numbrn.full.version"
let CheckAppFullVersionNotification = "CheckAppFullVersionNotification"

func onMainThread(closure: () -> ()) {
    onQueue(dispatch_get_main_queue(), closure: closure)
}

func inBackground(closure: () -> ()) {
    onQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), closure: closure)
}

private func onQueue(queue: dispatch_queue_t, closure: () -> ()) {
    dispatch_async(queue, closure)
}


let ReleaseBuild = true