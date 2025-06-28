import Foundation

class PersistenceManager: ObservableObject {
  private let userDefaults = UserDefaults.standard
  private let viewedStoriesKey = "viewedStories"
  private let likedStoriesKey = "likedStories"

  func markStoryAsViewed(_ userId: Int) {
    var viewedStories = getViewedStories()
    viewedStories.insert(userId)
    userDefaults.set(Array(viewedStories), forKey: viewedStoriesKey)
  }

  func getViewedStories() -> Set<Int> {
    let array = userDefaults.array(forKey: viewedStoriesKey) as? [Int] ?? []
    return Set(array)
  }

  func toggleLikeForStory(_ storyId: String) {
    var likedStories = getLikedStories()

    if likedStories.contains(storyId) {
      likedStories.remove(storyId)
    } else {
      likedStories.insert(storyId)
    }

    userDefaults.set(Array(likedStories), forKey: likedStoriesKey)
  }

  func isStoryLiked(_ storyId: String) -> Bool {
    getLikedStories().contains(storyId)
  }

  func getLikedStories() -> Set<String> {
    let array = userDefaults.array(forKey: likedStoriesKey) as? [String] ?? []
    return Set(array)
  }
}
