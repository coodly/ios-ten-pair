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
import Foundation

private let TenPairSaveDataKey = "NumbersGameSaveDataKey"

public struct FieldSave {
  public let save: ([Int]) -> Void
  public let load: (() -> [Int])
}

extension FieldSave {
  public static let live = FieldSave(
    save: {
      numbers in

      let defaults = UserDefaults.standard
      defaults.set(numbers, forKey: TenPairSaveDataKey)
      defaults.synchronize()
    },
    load: {
      UserDefaults.standard.value(forKey: TenPairSaveDataKey) as? [Int] ?? DefaultStartBoard
    }
  )
}

extension FieldSave {
  public static let active: FieldSave = .live
}

extension FieldSave {
  public static let noSave = FieldSave(
    save: {_ in },
    load: { fatalError() }
  )
}
