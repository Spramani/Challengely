import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    enum Sender { case user, ai }
    let id = UUID()
    let sender: Sender
    var text: String
    var isStreaming: Bool = false
}

struct ChallengeChatView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [ChatMessage] = [
        ChatMessage(sender: .ai, text: "Welcome to Challengely AI, how can I help?")
    ]
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @State private var isStreaming: Bool = false
    @State private var streamIndex: Int = 0
    @FocusState private var inputFocused: Bool
    private let charLimit = 500
    private let growingLineLimit = 3

    private let aiQuickReplies = [
        "I'm nervous about today's 30-minute meditation challenge. Any tips?",
        "I'm 10 minutes in and getting distracted. Help!",
        "I'm on day 7! How can I keep this momentum?",
        "hey whats the challenge?"
    ]

    private func aiReply(for userText: String) -> String? {
        let lower = userText.lowercased()
        if lower.contains("nervous") && lower.contains("meditation") {
            return "Start with just 5 minutes! Deep breathing is key. You've got this! 💪"
        }
        if lower.contains("10 minutes") || lower.contains("distract") {
            return "That's totally normal! Try counting your breaths from 1 to 10, then repeat. Focus on the present moment."
        }
        if lower.contains("streak") || lower.contains("day 7") || lower.contains("momentum") {
            return "Amazing streak! 🔥 Tomorrow's challenge will be even better. Consider setting a daily reminder!"
        }
        if lower.contains("what's the challenge") || lower.contains("whats the challenge") {
            return "Your challenge today is: 30 minutes of mindful meditation. Good luck!"
        }
        if lower.contains("so explain") {
            return "There are many programming languages in the market that are used in designing and building websites, various applications and other tasks. All these languages are popular in their place and in the way they are used, and many programmers learn and use them."
        }
        return nil
    }

    private func streamingInsert(_ text: String) {
        isStreaming = true
        var streamingText = ""
        let chars = Array(text)
        let id = UUID()
        messages.append(ChatMessage(sender: .ai, text: streamingText, isStreaming: true))
        streamIndex = messages.count - 1
        Task {
            for i in 0..<chars.count {
                try? await Task.sleep(nanoseconds: 22_000_000)
                streamingText.append(chars[i])
                messages[streamIndex].text = streamingText
            }
            messages[streamIndex].isStreaming = false
            isStreaming = false
        }
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty, inputText.count <= charLimit else { return }
        let userMsg = ChatMessage(sender: .user, text: inputText)
        messages.append(userMsg)
        let maybeAI = aiReply(for: inputText)
        inputText = ""
        if let ai = maybeAI {
            isTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isTyping = false
                streamingInsert(ai)
            }
        }
    }

    private func counterColor(_ count: Int) -> Color {
        if count < charLimit - 100 { return .white }
        if count < charLimit - 25 { return .white }
        if count < charLimit { return .white }
        return .red
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Only switches tab, does not dismiss entire ChallengeView.
                Button(action: {
                    selectedTab = 0
                    //dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(.leading, 8)
                }
                Text("Challengely AI")
                    .font(.title2)
                    
                    .padding(.vertical, 16)
                Spacer()
            }
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            HStack(alignment: .bottom, spacing: 8) {
                                if message.sender == .ai {
                                    Image(systemName: "ant.fill")
                                        .foregroundColor(.blue)
                                        .padding(.leading, 2)
                                }
                                VStack(alignment: message.sender == .user ? .trailing : .leading) {
                                    Text(message.text)
                                        .font(.system(size: 17))
                                        .foregroundColor(message.sender == .user ? .white : .black)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 12)
                                        .background(
                                            message.sender == .user ? Color.blue : Color(.systemGray6)
                                        )
                                        .cornerRadius(22, corners: message.sender == .user ? [.topLeft, .topRight, .bottomLeft] : [.topRight, .topLeft, .bottomRight])
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22)
                                                .stroke(message.sender == .user ? Color.blue.opacity(0.6) : Color(.systemGray4), lineWidth: 0)
                                        )
                                        .shadow(color: Color.black.opacity(0.03), radius: 2, y: 2)
                                }
                                if message.sender == .user {
                                    Spacer().frame(width: 12)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: message.sender == .user ? .trailing : .leading)
                            .transition(.move(edge: .bottom))
                        }
                        if isTyping {
                            HStack(alignment: .bottom, spacing: 8) {
                                Image(systemName: "ant.fill")
                                    .foregroundColor(.blue)
                                TypingIndicatorView()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 6)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 14)
                    .onChange(of: messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.22)) {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color.white)
            .onTapGesture { inputFocused = false }
            Spacer(minLength: 0)
            VStack(spacing: 2) {
                if !isStreaming && !isTyping {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(aiQuickReplies, id: \ .self) { phrase in
                                Button(action: { inputText = phrase; inputFocused = true }) {
                                    Text(phrase)
                                        .font(.system(size: 15))
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 7)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                    }
                    .transition(.move(edge: .bottom))
                }
                HStack(alignment: .bottom, spacing: 10) {
                    HStack(spacing: 0) {
                        ZStack(alignment: .leading) {
                            if inputText.isEmpty {
                                Text("Write your message")
                                    .foregroundColor(Color(.systemGray3))
                                    .padding(.horizontal, 18)
                            }
                            TextEditor(text: $inputText)
                                .frame(minHeight: 42, maxHeight: 42)
                                .focused($inputFocused)
                                .foregroundColor(.black)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.clear)
                                .onChange(of: inputText) { _ in
                                    if inputText.count > charLimit {
                                        inputText = String(inputText.prefix(charLimit))
                                    }
                                }
                                .padding(.trailing, 40)
                        }
                        .frame(minHeight: 42, maxHeight: 42)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color(.black).opacity(0.07), radius: 3, x: 0, y: 2)
                        .overlay(
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {}) {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(.systemGray3))
                                }
                                .padding(.trailing, 13)
                                Button(action: sendMessage) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                                .padding(.trailing, 6)
                            }
                        )
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 7)
                }
            }
            .background(Color.white.ignoresSafeArea(edges: .bottom))
            .animation(.easeOut(duration: 0.22), value: inputText.isEmpty)
        }
        .background(Color(.systemGray5).opacity(0.18))
        .ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .tabBar)
    }
       
}

struct TypingIndicatorView: View {
    @State private var phase: Int = 0
    private let dotCount = 3
    private let dotSize: CGFloat = 7
    private let animation = Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: false)
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<dotCount, id: \ .self) { i in
                Circle()
                    .fill(Color(.systemGray2))
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(phase == i ? 1.2 : 0.85)
                    .opacity(phase == i ? 1 : 0.5)
            }
        }
        .padding(.vertical, 14)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.44, repeats: true) { _ in
                phase = (phase + 1) % dotCount
            }
        }
    }
}

// Helper for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Preview
#Preview {
    ChallengeChatView(selectedTab: .constant(1))
}
