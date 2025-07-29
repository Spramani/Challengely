// ProfileView.swift
// This is the Profile tab's main view controller for the TabView in ChallengeView.

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            Text("Your Profile")
                .font(.largeTitle.bold())
                .padding(.top, 12)
            Text("Welcome to your profile page!")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            Spacer()
        }
        .padding()
    //    .background(Color(red: 234/255, green: 244/255, blue: 255/255).ignoresSafeArea())
        
    }
}

#Preview {
    ProfileView()
}
