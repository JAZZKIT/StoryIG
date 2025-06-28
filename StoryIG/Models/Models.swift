import Foundation

struct User: Codable, Identifiable, Hashable {
  let id: Int
  let name: String
  let profilePictureUrl: String

  enum CodingKeys: String, CodingKey {
    case id, name
    case profilePictureUrl = "profile_picture_url"
  }
}

struct Story: Identifiable, Hashable {
  let id: String
  let userId: Int
  let imageUrl: String
  let timestamp: Date

  init(userId: Int, imageIndex: Int) {
    self.id = "\(userId)_\(imageIndex)"
    self.userId = userId
    let seed = userId * 1000 + imageIndex
    self.imageUrl = "https://picsum.photos/seed/\(seed)/400/700"
    self.timestamp = Date()
  }
}

struct UserStory: Identifiable, Hashable {
  let id: Int
  let user: User
  let stories: [Story]
  var isViewed: Bool
  var likedStoryIds: Set<String>

  init(user: User, stories: [Story], isViewed: Bool = false, likedStoryIds: Set<String> = []) {
    self.id = user.id
    self.user = user
    self.stories = stories
    self.isViewed = isViewed
    self.likedStoryIds = likedStoryIds
  }
}

struct UserPage: Codable {
  let users: [User]
}

struct UserData: Codable {
  let pages: [UserPage]
}
