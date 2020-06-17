/*
* Copyright 2020 Coodly LLC
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

import GameplayKit

internal class PlayState: GKState {
    fileprivate weak var delegate: PlayDelegate?
    internal init(delegate: PlayDelegate) {
        self.delegate = delegate
    }
}

internal class SelectingNumber: PlayState {
    override func didEnter(from previousState: GKState?) {
        delegate?.clearSelection()
    }
}

internal class AnimatingSuccess: PlayState {
    override func didEnter(from previousState: GKState?) {
        delegate?.animateSuccess()
    }
}

internal class AnimatingFailure: PlayState {
    override func didEnter(from previousState: GKState?) {
        delegate?.animateFailure()
    }
}
