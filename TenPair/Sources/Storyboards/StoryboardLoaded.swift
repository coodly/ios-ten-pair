import Foundation

@MainActor
public protocol StoryboardLoaded: AnyObject {
  static var storyboardName: String { get }
}
