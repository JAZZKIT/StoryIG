import Foundation

class DataManager: ObservableObject {
  @Published var userStories: [UserStory] = []
  @Published var isLoading = false
  
  private let persistenceManager = PersistenceManager()
  private var currentPage = 0
  private let pageSize = 10
  
  private let allUsers = [
    User(id: 1, name: "Neo", profilePictureUrl: "https://i.pravatar.cc/300?u=1"),
    User(id: 2, name: "Trinity", profilePictureUrl: "https://i.pravatar.cc/300?u=2"),
    User(id: 3, name: "Morpheus", profilePictureUrl: "https://i.pravatar.cc/300?u=3"),
    User(id: 4, name: "Smith", profilePictureUrl: "https://i.pravatar.cc/300?u=4"),
    User(id: 5, name: "Oracle", profilePictureUrl: "https://i.pravatar.cc/300?u=5"),
    User(id: 6, name: "Cypher", profilePictureUrl: "https://i.pravatar.cc/300?u=6"),
    User(id: 7, name: "Niobe", profilePictureUrl: "https://i.pravatar.cc/300?u=7"),
    User(id: 8, name: "Dozer", profilePictureUrl: "https://i.pravatar.cc/300?u=8"),
    User(id: 9, name: "Switch", profilePictureUrl: "https://i.pravatar.cc/300?u=9"),
    User(id: 10, name: "Tank", profilePictureUrl: "https://i.pravatar.cc/300?u=10"),
    User(id: 11, name: "Seraph", profilePictureUrl: "https://i.pravatar.cc/300?u=11"),
    User(id: 12, name: "Sati", profilePictureUrl: "https://i.pravatar.cc/300?u=12"),
    User(id: 13, name: "Merovingian", profilePictureUrl: "https://i.pravatar.cc/300?u=13"),
    User(id: 14, name: "Persephone", profilePictureUrl: "https://i.pravatar.cc/300?u=14"),
    User(id: 15, name: "Ghost", profilePictureUrl: "https://i.pravatar.cc/300?u=15"),
    User(id: 16, name: "Lock", profilePictureUrl: "https://i.pravatar.cc/300?u=16"),
    User(id: 17, name: "Rama", profilePictureUrl: "https://i.pravatar.cc/300?u=17"),
    User(id: 18, name: "Bane", profilePictureUrl: "https://i.pravatar.cc/300?u=18"),
    User(id: 19, name: "The Keymaker", profilePictureUrl: "https://i.pravatar.cc/300?u=19"),
    User(id: 20, name: "Commander Thadeus", profilePictureUrl: "https://i.pravatar.cc/300?u=20"),
    User(id: 21, name: "Kid", profilePictureUrl: "https://i.pravatar.cc/300?u=21"),
    User(id: 22, name: "Zee", profilePictureUrl: "https://i.pravatar.cc/300?u=22"),
    User(id: 23, name: "Mifune", profilePictureUrl: "https://i.pravatar.cc/300?u=23"),
    User(id: 24, name: "Roland", profilePictureUrl: "https://i.pravatar.cc/300?u=24"),
    User(id: 25, name: "Cas", profilePictureUrl: "https://i.pravatar.cc/300?u=25"),
    User(id: 26, name: "Colt", profilePictureUrl: "https://i.pravatar.cc/300?u=26"),
    User(id: 27, name: "Vector", profilePictureUrl: "https://i.pravatar.cc/300?u=27"),
    User(id: 28, name: "Sequoia", profilePictureUrl: "https://i.pravatar.cc/300?u=28"),
    User(id: 29, name: "Sentinel", profilePictureUrl: "https://i.pravatar.cc/300?u=29"),
    User(id: 30, name: "Turing", profilePictureUrl: "https://i.pravatar.cc/300?u=30")
  ]
  
  func loadInitialData() {
    guard userStories.isEmpty else { return }
    loadMoreStories()
  }
  
  func loadMoreStories() {
    guard !isLoading else { return }
    
    isLoading = true
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      let users = self.getUsersForPage(self.currentPage)
      let newUserStories = self.createUserStories(from: users)
      
      self.userStories.append(contentsOf: newUserStories)
      self.currentPage += 1
      self.isLoading = false
    }
  }
  
  private func getUsersForPage(_ page: Int) -> [User] {
    let startIndex = (page * pageSize) % allUsers.count
    var pageUsers: [User] = []
    
    for i in 0..<pageSize {
      let index = (startIndex + i) % allUsers.count
      pageUsers.append(allUsers[index])
    }
    
    return pageUsers
  }
  
  private func createUserStories(from users: [User]) -> [UserStory] {
    let viewedStories = persistenceManager.getViewedStories()
    let likedStories = persistenceManager.getLikedStories()
    
    return users.map { user in
      let stories = createStoriesForUser(user)
      let isViewed = viewedStories.contains(user.id)
      let userLikedStories = Set(stories.compactMap { story in
        likedStories.contains(story.id) ? story.id : nil
      })
      
      return UserStory(
        user: user,
        stories: stories,
        isViewed: isViewed,
        likedStoryIds: userLikedStories
      )
    }
  }
  
  private func createStoriesForUser(_ user: User) -> [Story] {
    let storyCount = Int.random(in: 1...4)
    return (0..<storyCount).map { index in
      Story(userId: user.id, imageIndex: index)
    }
  }
  
  func markStoryAsViewed(_ userStory: UserStory) {
    persistenceManager.markStoryAsViewed(userStory.user.id)
    
    if let index = userStories.firstIndex(where: { $0.id == userStory.id }) {
      userStories[index] = UserStory(
        user: userStory.user,
        stories: userStory.stories,
        isViewed: true,
        likedStoryIds: userStory.likedStoryIds
      )
    }
  }
  
  func toggleLikeForStory(_ story: Story, in userStory: UserStory) {
    persistenceManager.toggleLikeForStory(story.id)
    
    if let index = userStories.firstIndex(where: { $0.id == userStory.id }) {
      var updatedLikedStories = userStory.likedStoryIds
      
      if updatedLikedStories.contains(story.id) {
        updatedLikedStories.remove(story.id)
      } else {
        updatedLikedStories.insert(story.id)
      }
      
      userStories[index] = UserStory(
        user: userStory.user,
        stories: userStory.stories,
        isViewed: userStory.isViewed,
        likedStoryIds: updatedLikedStories
      )
    }
  }
}
