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

internal typealias PlatformView = UIView
public typealias LayoutGuide = UILayoutGuide
public typealias Metrics = [String : Any]?
public typealias GameEdgeInsets = UIEdgeInsets
public typealias LayoutAttribute = NSLayoutConstraint.Attribute
public typealias LayoutRelation = NSLayoutConstraint.Relation
public typealias LayoutFormatOptions = NSLayoutConstraint.FormatOptions
public typealias StringDrawingOptions = NSStringDrawingOptions

public func EdgeInsetsMake(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> GameEdgeInsets {
    return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
}

internal let InFlippedEnv = false
