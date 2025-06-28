import SwiftUI

struct StoryDetailView: View {
  let userStory: UserStory
  let allUserStories: [UserStory]
  let onLikeToggle: (Story) -> Void
  let onUserChange: (UserStory) -> Void
  let onDismiss: () -> Void
  
  @State private var currentStoryIndex = 0
  @State private var currentUserIndex = 0
  @State private var progress: Double = 0
  @State private var timer: Timer?
  @State private var isPaused = false
  @State private var isTransitioning = false
  
  private let storyDuration: Double = 4.0
  private let timerInterval: Double = 1.0 / 60.0
  
  var currentUserStory: UserStory {
    guard currentUserIndex < allUserStories.count else { return userStory }
    return allUserStories[currentUserIndex]
  }
  
  var currentStory: Story {
    guard currentStoryIndex < currentUserStory.stories.count else {
      return currentUserStory.stories.first ?? Story(userId: 0, imageIndex: 0)
    }
    return currentUserStory.stories[currentStoryIndex]
  }
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      AsyncImage(url: URL(string: currentStory.imageUrl)) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .transition(.opacity.combined(with: .scale(scale: 1.05)))
          .animation(.easeInOut(duration: 0.3), value: currentStory.id)
      } placeholder: {
        Rectangle()
          .fill(Color.black)
      }
      .clipped()
      .onTapGesture { location in
        handleTap(at: location)
      }
      .onLongPressGesture(minimumDuration: 0.1) {
        pauseStory()
      } onPressingChanged: { pressing in
        if !pressing {
          resumeStory()
        }
      }
      
      VStack {
        progressBars
        headerView
        Spacer()
        bottomControls
      }
    }
    .onAppear {
      setupInitialState()
      startStoryTimer()
      preloadNextImages()
    }
    .onDisappear {
      stopStoryTimer()
    }
    .statusBarHidden()
  }
  
  private var progressBars: some View {
    HStack(spacing: 4) {
      ForEach(0..<currentUserStory.stories.count, id: \.self) { index in
        GeometryReader { geometry in
          Rectangle()
            .fill(Color.white.opacity(0.3))
            .frame(height: 2)
            .overlay(
              Rectangle()
                .fill(Color.white)
                .frame(
                  width: progressWidth(for: index, totalWidth: geometry.size.width),
                  height: 2
                )
                .animation(.linear(duration: timerInterval), value: progress),
              alignment: .leading
            )
        }
        .frame(height: 2)
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
  }
  
  private var headerView: some View {
    HStack(spacing: 12) {
      AsyncImage(url: URL(string: currentUserStory.user.profilePictureUrl)) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        Circle()
          .fill(Color.clear)
      }
      .frame(width: 32, height: 32)
      .clipShape(Circle())
      
      Text(currentUserStory.user.name)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .animation(.easeInOut(duration: 0.2), value: currentUserStory.user.name)
      
      Spacer()
      
      Button(action: onDismiss) {
        Image(systemName: "xmark")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.white)
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
  }
  
  private var bottomControls: some View {
    HStack {
      Spacer()
      
      VStack(spacing: 16) {
        Button(action: {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            onLikeToggle(currentStory)
          }
        }) {
          Image(systemName: currentUserStory.likedStoryIds.contains(currentStory.id) ? "heart.fill" : "heart")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(currentUserStory.likedStoryIds.contains(currentStory.id) ? .red : .white)
            .scaleEffect(currentUserStory.likedStoryIds.contains(currentStory.id) ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentUserStory.likedStoryIds.contains(currentStory.id))
        }
      }
      .padding(.trailing, 20)
      .padding(.bottom, 50)
    }
  }
  
  private func setupInitialState() {
    if let userIndex = allUserStories.firstIndex(where: { $0.id == userStory.id }) {
      currentUserIndex = userIndex
    }
    currentStoryIndex = 0
    progress = 0
  }
  
  private func handleTap(at location: CGPoint) {
    let screenWidth = UIScreen.main.bounds.width
    let tapThreshold = screenWidth / 3
    
    if location.x < tapThreshold {
      goToPreviousStory()
    } else if location.x > screenWidth - tapThreshold {
      goToNextStory()
    }
  }
  
  private func startStoryTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
      if !isPaused && !isTransitioning {
        withAnimation(.linear(duration: timerInterval)) {
          progress += timerInterval / storyDuration
        }
        
        if progress >= 1.0 {
          goToNextStory()
        }
      }
    }
  }
  
  private func stopStoryTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func pauseStory() {
    isPaused = true
  }
  
  private func resumeStory() {
    isPaused = false
  }
  
  private func goToNextStory() {
    guard !isTransitioning else { return }
    
    isTransitioning = true
    
    if currentStoryIndex < currentUserStory.stories.count - 1 {
      withAnimation(.easeInOut(duration: 0.3)) {
        currentStoryIndex += 1
        progress = 0
      }
      preloadNextImages()
    } else {
      goToNextUser()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      isTransitioning = false
    }
  }
  
  private func goToPreviousStory() {
    guard !isTransitioning else { return }
    
    isTransitioning = true
    
    if currentStoryIndex > 0 {
      withAnimation(.easeInOut(duration: 0.3)) {
        currentStoryIndex -= 1
        progress = 0
      }
      preloadNextImages()
    } else {
      goToPreviousUser()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      isTransitioning = false
    }
  }
  
  private func goToNextUser() {
    if currentUserIndex < allUserStories.count - 1 {
      withAnimation(.easeInOut(duration: 0.3)) {
        currentUserIndex += 1
        currentStoryIndex = 0
        progress = 0
      }
      onUserChange(currentUserStory)
    } else {
      onDismiss()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      isTransitioning = false
    }
  }
  
  private func goToPreviousUser() {
    if currentUserIndex > 0 {
      withAnimation(.easeInOut(duration: 0.3)) {
        currentUserIndex -= 1
        currentStoryIndex = currentUserStory.stories.count - 1
        progress = 0
      }
      onUserChange(currentUserStory)
    } else {
      onDismiss()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      isTransitioning = false
    }
  }
  
  private func progressWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
    if index < currentStoryIndex {
      return totalWidth
    } else if index == currentStoryIndex {
      return totalWidth * progress
    } else {
      return 0
    }
  }
}

extension StoryDetailView {
  private func preloadNextImages() {
    if currentStoryIndex < currentUserStory.stories.count - 1 {
      let nextStory = currentUserStory.stories[currentStoryIndex + 1]
      preloadImage(url: nextStory.imageUrl)
    }

    if currentUserIndex < allUserStories.count - 1 {
      let nextUserStory = allUserStories[currentUserIndex + 1]
      if let firstStory = nextUserStory.stories.first {
        preloadImage(url: firstStory.imageUrl)
      }
    }
  }
  
  private func preloadImage(url: String) {
    guard let imageUrl = URL(string: url) else { return }
    
    Task {
      do {
        let (_, _) = try await URLSession.shared.data(from: imageUrl)
      } catch {
      }
    }
  }
}
