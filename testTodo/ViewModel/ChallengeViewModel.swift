// ChallengeViewModel.swift
// ViewModel for ChallengeView in MVVM pattern

import Combine
import SwiftUI

/// ViewModel holding data and logic for the daily challenge
class ChallengeViewModel: ObservableObject {
    // User's name
    @Published var userName: String = "Shubham" // Replace with user source later

    // Challenge details
    @Published var date: String = "7/23"
    @Published var challengeTitle: String = "Read a book"
    @Published var description: String = "Reading is good. Aim for 10 pages today!"
    @Published var estimatedTime: String = "30 minutes"
    @Published var difficultyLabel: String = "Easy"
    
    // Add more properties/logic here for challenge actions (accepting, completing, etc.)
}
