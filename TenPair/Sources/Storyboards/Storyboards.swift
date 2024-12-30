import UIKit

@MainActor
public class Storyboards {
  public static func loadFromStoryboard<C: StoryboardLoaded>(from bundle: Bundle) -> C {
    return UIStoryboard(name: C.storyboardName, bundle: bundle).instantiateInitialViewController() as! C
  }
}
