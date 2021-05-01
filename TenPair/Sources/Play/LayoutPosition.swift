/*
* Copyright 2021 Coodly LLC
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

import Config

public struct LayoutPosition {
    private let showingAds: Bool
    private let adAfterLines: Int
    public init(showingAds: Bool, adAfterLines: Int) {
        self.showingAds = showingAds
        self.adAfterLines = adAfterLines
    }
    
    public func numberOfSections(with field: [Int]) -> Int {
        guard showingAds else {
            return 1
        }
        
        let tilesInSection = NumberOfColumns * adAfterLines
        let fullTilesSections = field.count / tilesInSection
        let partial = field.count % tilesInSection != 0
        return fullTilesSections + fullTilesSections + (partial ? 1 : 0)
    }
}
