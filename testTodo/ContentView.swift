//
//  ContentView.swift
//  testTodo
//
//  Created by Shubham Ramani on 28/07/25.
//

import SwiftUI

struct ContentView: View {
    enum OnboardingStep { case welcome, interests, difficulty }
    @State private var step: OnboardingStep = .welcome
    @State private var selectedInterests: Set<Int> = []
    @State private var difficulty: Double = 0.0
    @State private var showChallengeScreen = false
    
    let interests = ["Fitness", "creativity", "mindfulness", "learning", "social"]
    let blueColor = Color(red: 34/255, green: 122/255, blue: 242/255)
    let bgColor = Color(red: 234/255, green: 244/255, blue: 255/255)
    
    var stepProgress: Double {
        switch step {
        case .welcome: return 0.0
        case .interests: return 0.33
        case .difficulty: return 0.66
        }
    }
    var stepButtonTitle: String {
        switch step {
        case .welcome: return "Get started"
        case .interests: return "Continue"
        case .difficulty: return "Complete Profile"
        }
    }
    @ViewBuilder
    var stepContent: some View {
        switch step {
        case .welcome:
            VStack(spacing: 32) {
                Spacer()
                VStack(spacing: 22) {
                    Text("Welcome to")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    Text("Challengely")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(blueColor)
                    Image(systemName: "checkmark")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundColor(blueColor)
                        .padding(.top, 12)
                }
                Spacer()
            }
        case .interests:
           
                VStack {
                    Text("Choose your interests")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 15)
                    Text("Choose up to 3 interests to personalize your challenges")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.top, 1)
                    GeometryReader { geometry in
                       Spacer()
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            ForEach(interests.indices, id: \.self) { idx in
                                Button {
                                    if selectedInterests.contains(idx) {
                                        selectedInterests.remove(idx)
                                    } else if selectedInterests.count < 3 {
                                        selectedInterests.insert(idx)
                                    }
                                } label: {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(selectedInterests.contains(idx) ? blueColor : blueColor.opacity(0.4), lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(selectedInterests.contains(idx) ? blueColor.opacity(0.20) : Color.white)
                                        )
                                        .frame(width: max((geometry.size.width / 2.2) - 55, 44), height: max((geometry.size.width / 2.2) - 55, 44))
                                        .overlay(
                                            Text(interests[idx])
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(selectedInterests.contains(idx) ? blueColor : .black)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                        Spacer()
                    }
                    Spacer()
                
            }
        case .difficulty:
            VStack {
                Text("Set your challenge level")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 15)
                Text("How tough do you want your challenges to be?")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.black.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                    .padding(.bottom, 32)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(blueColor.opacity(0.2))
                        .frame(height: 12)
                    Capsule()
                        .fill(blueColor)
                        .frame(width: CGFloat(22 + difficulty * 250), height: 12)
                    Circle()
                        .fill(Color.white)
                        .overlay(
                            Circle()
                                .stroke(blueColor, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.10), radius: 2, y: 1)
                        .frame(width: 32, height: 32)
                        .offset(x: CGFloat(difficulty * 250))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { val in
                                    let newX = min(max(0, val.location.x - 16), 250)
                                    difficulty = Double(newX / 250)
                                }
                        )
                }
                .frame(width: 272, height: 32)
                .padding(.bottom, 18)
                HStack {
                    Text("Easy")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(difficulty < 0.3 ? blueColor : .black)
                    Spacer()
                    Text("Medium")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor((difficulty >= 0.3 && difficulty < 0.9) ? blueColor : .black)
                    Spacer()
                    Text("Hard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(difficulty >= 0.9 ? .red : .black)
                }
                .frame(width: 272)
                .padding(.bottom, 32)
                Spacer()
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            if step != .welcome {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(blueColor.opacity(0.2))
                        .frame(height: 6)
                    Capsule()
                        .fill(blueColor)
                        .frame(width: 240 * stepProgress, height: 6)
                        .animation(.easeInOut, value: step)
                }
                .frame(height: 30)
                .frame(width: 240)
                .padding(.top, 38)
            }

            Spacer(minLength: 12)

            // Main Animated Content
            ZStack {
                stepContent
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .animation(.easeInOut, value: step)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer(minLength: 12)

            // Bottom Button
            Button {
                withAnimation {
                    if step == .welcome {
                        step = .interests
                    } else if step == .interests {
                        step = .difficulty
                    } else {
                        showChallengeScreen = true
                    }
                }
            } label: {
                Text(stepButtonTitle)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(
                        Capsule()
                            .fill(step == .interests && selectedInterests.isEmpty ? Color.gray.opacity(0.5) : blueColor)
                            .animation(.easeInOut, value: selectedInterests)
                    )
            }
            .disabled(step == .interests && selectedInterests.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 38)
        }
        .background(bgColor.ignoresSafeArea())
        .fullScreenCover(isPresented: $showChallengeScreen) {
            ChallengeView()
        }
    }
}

#Preview {
    ContentView()
}
