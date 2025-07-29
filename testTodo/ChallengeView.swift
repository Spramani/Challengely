// ChallengeView for after onboarding completion
import SwiftUI
import Combine

// MARK: - OtherTabView
struct OtherTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "bubble.left")
                .resizable()
                .frame(width: 54, height: 48)
                .foregroundColor(.blue)
            Text("Other Tab ViewController")
                .font(.title2.bold())
                .padding(.top, 16)
            Spacer()
        }
    }
}

// MARK: - ChallengeView (The main challenge screen)
struct ChallengeView: View {
    // MARK: - Challenge States
    enum ChallengeState {
        case locked, revealed, inProgress, completed
    }

    // MARK: - State Properties
    @State private var selectedTab = 0
    @StateObject private var viewModel = ChallengeViewModel()

    @State private var challengeState: ChallengeState = .locked

    // Timer/Progress
    @State private var progress: Double = 0
    @State private var timer: Timer? = nil

    // Confetti
    @State private var showConfetti = false

    // Share Sheet
    @State private var showShareSheet = false
    @State private var shareImage: UIImage? = nil

    // For cycling challenges (simple example with 3 challenges)
    @State private var challengeIndex = 0
    private let challenges = [
        (
            title: "Morning Stretch",
            description: "Start your day with a 5-minute stretch to boost your energy.",
            estimatedTime: "5 mins",
            difficultyLabel: "Easy"
        ),
        (
            title: "Mindful Breathing",
            description: "Take 10 minutes to practice mindful breathing and reduce stress.",
            estimatedTime: "10 mins",
            difficultyLabel: "Medium"
        ),
        (
            title: "Evening Journaling",
            description: "Reflect on your day and write down your thoughts and goals.",
            estimatedTime: "15 mins",
            difficultyLabel: "Medium"
        )
    ]

    // Updates challenge data based on challengeIndex
    private func updateChallenge() {
        let challenge = challenges[challengeIndex]
        viewModel.challengeTitle = challenge.title
        viewModel.description = challenge.description
        viewModel.estimatedTime = challenge.estimatedTime
        viewModel.difficultyLabel = challenge.difficultyLabel
    }

    // Resets progress and timer
    private func resetProgress() {
        timer?.invalidate()
        timer = nil
        progress = 0
    }

    // Starts progress timer (simulate progress for demo)
    private func startProgressTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                if progress < 1 {
                    progress += 0.01
                } else {
                    timer?.invalidate()
                    timer = nil
                    challengeState = .completed
                    showConfetti = true
                }
            }
        }
    }

    // MARK: - Challenge Card (UI for the day's challenge)
    var mainChallengeTab: some View {
        // Wrap entire content in ZStack for overlays depending on challengeState
        ZStack {
            // Background card with conditional blur or normal depending on state
            VStack(spacing: 0) {
                // Greeting
                HStack {
                    Spacer()
                    Text("Good Morning, \(viewModel.userName)!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 32)

                // Challenge Card Content
                VStack(alignment: .center, spacing: 10) {
                    Text("\(viewModel.date) Challenge")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue.opacity(0.75))
                        .padding(.bottom, 2)
                    Text(viewModel.challengeTitle)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 34 / 255, green: 122 / 255, blue: 242 / 255))
                        .multilineTextAlignment(.center)

                    Text(viewModel.description)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.black.opacity(0.85))
                        .lineSpacing(3)
                        .padding(.vertical, 1)
                        .multilineTextAlignment(.center)

                    Divider()
                        .padding(.vertical, 4)

                    HStack {
                        Label("Estimated Time", systemImage: "clock")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(viewModel.estimatedTime)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Divider()
                        .padding(.vertical, 4)

                    HStack {
                        Label("Difficulty", systemImage: "flame.fill")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(viewModel.difficultyLabel)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(9)
                    }
                    .padding(.bottom, challengeState == .inProgress ? 100 : 100)

                    // Show ProgressView if inProgress
                    if challengeState == .inProgress {
//                        ProgressView(value: progress)
//                            .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
//                            .padding(.horizontal, 28)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.10), radius: 18, y: 8)
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                // MARK: - Accept Challenge Button or Placeholder based on state
                if challengeState == .locked {
                    // Button disabled in locked state
                    Button {
                        // No action
                    } label: {
                        Text("Accept Challenge")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.gray.opacity(0.5))
                            )
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 50)
                    .disabled(true)
                    .opacity(0.6)
                }
                else if challengeState == .revealed {
                    // Accept Challenge button with scale animation
                    Button {
                        withAnimation(.easeInOut(duration: 0.2).delay(0)) {
                            challengeState = .inProgress
                            startProgressTimer()
                        }
                    } label: {
                        Text("Accept Challenge")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color(red: 34 / 255, green: 122 / 255, blue: 242 / 255))
                                    .shadow(color: Color.blue.opacity(0.17), radius: 7, y: 2)
                            )
                            .scaleEffect(challengeState == .revealed ? 1.0 : 0.95)
                            .animation(.easeInOut(duration: 0.15), value: challengeState)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 50)
                }
                else if challengeState == .inProgress {
                    // During progress, show disabled button
                    Button {
                            // No action during progress
                        } label: {
                            ZStack(alignment: .leading) {
                                // Background progress bar
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.gray.opacity(0.7))
                                    .overlay(
                                        GeometryReader { geo in
                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                .fill(Color.blue)
                                                .frame(width: geo.size.width * progress)
                                                .animation(.linear(duration: 0.1), value: progress)
                                        }
                                    )
                                
                                // Button text centered
                                HStack {
                                    Spacer()
                                    Text("In Progress...")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            .frame(height: 58)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 50)
                        .disabled(true)                }
                else if challengeState == .completed {
                    // Completed state, hide button area so confetti and Share button show on top
                    Spacer().frame(height: 90)
                }

                Spacer()
            }
            .blur(radius: challengeState == .locked ? 8 : 0)
            .opacity(challengeState == .locked ? 0.6 : 1.0)
            .animation(.easeInOut, value: challengeState)

            // Overlays depending on challengeState
            switch challengeState {
            case .locked:
                VStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            challengeState = .revealed
                        }
                    } label: {
                        Text("Tap to reveal")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 34 / 255, green: 122 / 255, blue: 242 / 255))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .scaleEffect(challengeState == .locked ? 1.0 : 0.8)
                            .opacity(challengeState == .locked ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.3), value: challengeState)
                    }
                    .padding(.bottom, 120)
                }
                .transition(.opacity)

            case .revealed:
                EmptyView()

            case .inProgress:
                EmptyView()

            case .completed:
                // Celebration overlay
                
                VStack(spacing: 20) {
                    Spacer()
                    // Placeholder confetti effect
                    Text("🎉🎉🎉")
                        .font(.system(size: 72))
                        .scaleEffect(showConfetti ? 1.1 : 0.9)
                        .opacity(showConfetti ? 1.0 : 0.7)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showConfetti)
                    
                    Button {
                        // Show share sheet
                        // Stub: use dummy image for now
                        shareImage = UIImage(systemName: "star.fill") // Replace with actual rendered challenge image
                        showShareSheet = true
                    } label: {
                        Text("Share")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 160, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.purple)
                            )
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 150)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color.white.opacity(0.9).ignoresSafeArea())
                .transition(.opacity)
                .onAppear {
                    withAnimation {
                        showConfetti = false
                    }
                }
                
                // Close button at top right
                VStack {
                    HStack {
                        Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    challengeState = .revealed
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        Spacer()
                    }

            }
        }
        // Refreshable modifier to cycle challenges and reset state
        .refreshable {
            // Cycle challenge index
            challengeIndex = (challengeIndex + 1) % challenges.count
            updateChallenge()
            challengeState = .locked
            resetProgress()
            showConfetti = false
        }
        // Share sheet presentation
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(activityItems: [])
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: { showShareSheet = false }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 28))
//                            .foregroundColor(.gray)
//                            .padding()
//                    }
//                }
//                if let shareImage {
//                    ActivityViewController(activityItems: [shareImage])
//                }
//                Spacer()
//            }
//            .presentationDetents([.medium, .large])
        }
        .onAppear {
            updateChallenge()
        }
    }

    /// Main tab view for challenge flow and navigation.
    var body: some View {
        TabView(selection: $selectedTab) {
            mainChallengeTab
                .tag(0)
                .background(Color(red: 234 / 255, green: 244 / 255, blue: 255 / 255).ignoresSafeArea())
                .tabItem {
                    Image(systemName: "rectangle.on.rectangle")
                    Text("Challenge")
                }
            ChallengeChatView(selectedTab: $selectedTab)
                .tag(1)
                .background(Color(red: 234 / 255, green: 244 / 255, blue: 255 / 255).ignoresSafeArea())
                .tabItem {
                    Image(systemName: "bubble.left")
                    Text("Other")
                }

            ProfileView()
                .tag(2)
              //  .background(Color(red: 234/255, green: 244/255, blue: 255/255).ignoresSafeArea())
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
        }
        .accentColor(Color(red: 34 / 255, green: 122 / 255, blue: 242 / 255))
    }
}

// Wrapper for UIActivityViewController to enable share sheet
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

#Preview {
    ChallengeView()
}
