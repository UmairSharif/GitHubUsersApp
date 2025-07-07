//
//  UserListView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct UserListView: View {
    @State private var searchText = ""
    
    // Static mock data for design
    private let mockUsers = [
        GitHubUser(
            id: 1,
            login: "octocat",
            avatarURL: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false,
            name: "The Octocat",
            bio: "GitHub's mascot and octocat extraordinaire! 🐙",
            followers: 1234,
            following: 567,
            publicRepos: 89
        ),
        GitHubUser(
            id: 2,
            login: "johndoe",
            avatarURL: "https://avatars.githubusercontent.com/u/2?v=4",
            type: "User",
            siteAdmin: false,
            name: "John Doe",
            bio: "Software developer passionate about open source",
            followers: 456,
            following: 234,
            publicRepos: 45
        ),
        GitHubUser(
            id: 3,
            login: "janedoe",
            avatarURL: "https://avatars.githubusercontent.com/u/3?v=4",
            type: "User",
            siteAdmin: false,
            name: "Jane Doe",
            bio: "Full-stack developer and tech enthusiast",
            followers: 789,
            following: 123,
            publicRepos: 67
        ),
        GitHubUser(
            id: 4,
            login: "developer",
            avatarURL: "https://avatars.githubusercontent.com/u/4?v=4",
            type: "User",
            siteAdmin: false,
            name: "Developer",
            bio: "Building amazing things with code",
            followers: 321,
            following: 89,
            publicRepos: 23
        ),
        GitHubUser(
            id: 5,
            login: "coder",
            avatarURL: "https://avatars.githubusercontent.com/u/5?v=4",
            type: "User",
            siteAdmin: false,
            name: "Code Master",
            bio: "Passionate about clean code and best practices",
            followers: 654,
            following: 432,
            publicRepos: 78
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(
                text: $searchText,
                placeholder: "Search GitHub users..."
            ) {
                // Static search action
                print("Search tapped with: \(searchText)")
            }
            
            // Show different states based on search text
            if searchText.isEmpty {
                initialStateView
            } else if mockUsers.filter({ $0.login.localizedCaseInsensitiveContains(searchText) }).isEmpty {
                emptyStateView
            } else {
                userListView
            }
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("GitHub Users")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("Settings tapped")
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
    }
    
    private var initialStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            
            Text("Discover GitHub Users")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            Text("Search for GitHub users to explore their repositories and contributions.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            
            Text("No users found")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            Text("Try adjusting your search terms or browse popular users.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var userListView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(mockUsers.filter { searchText.isEmpty || $0.login.localizedCaseInsensitiveContains(searchText) }) { user in
                    UserRowView(user: user) {
                        print("Selected user: \(user.login)")
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

#Preview {
    NavigationStack {
        UserListView()
    }
} 