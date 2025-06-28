import SwiftUI

struct StoriesMainView: View {
  @StateObject private var dataManager = DataManager()
  @State private var selectedUserStory: UserStory?
  
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
  
  var body: some View {
    NavigationView {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 20) {
          ForEach(dataManager.userStories) { userStory in
            StoryPreviewCard(userStory: userStory) {
              selectedUserStory = userStory
              dataManager.markStoryAsViewed(userStory)
            }
            .onAppear {
              if userStory.id == dataManager.userStories.last?.id {
                dataManager.loadMoreStories()
              }
            }
          }
          
        }
        .padding()
      }
      .navigationTitle("Stories")
      .navigationBarTitleDisplayMode(.large)
    }
    .onAppear {
      dataManager.loadInitialData()
    }
    .fullScreenCover(item: $selectedUserStory) { userStory in
      StoryDetailView(
        userStory: userStory,
        allUserStories: dataManager.userStories,
        onLikeToggle: { story in
          dataManager.toggleLikeForStory(story, in: userStory)
        },
        onUserChange: { newUserStory in
          dataManager.markStoryAsViewed(newUserStory)
        },
        onDismiss: {
          selectedUserStory = nil
        }
      )
    }
  }
}
