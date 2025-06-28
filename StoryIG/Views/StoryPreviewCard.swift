import SwiftUI

struct StoryPreviewCard: View {
  let userStory: UserStory
  let onTap: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      AsyncImage(url: URL(string: userStory.user.profilePictureUrl)) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        Circle()
          .fill(Color.clear)
      }
      .frame(width: 80, height: 80)
      .clipShape(Circle())
      .overlay(
        Circle()
          .stroke(
            userStory.isViewed ?
            LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom) :
              LinearGradient(
                colors: [.pink, .purple, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              ),
            lineWidth: 3
          )
      )
      .onTapGesture {
        onTap()
      }

      Text(userStory.user.name)
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .lineLimit(1)
        .frame(maxWidth: 80)
    }
  }
}

