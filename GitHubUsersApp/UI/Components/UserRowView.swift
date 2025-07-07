//
//  UserRowView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct UserRowView: View {
    let user: GitHubUser
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                UserAvatarView(
                    imageURL: user.avatarURL,
                    size: 50,
                    username: user.login
                )
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(user.login)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.githubText)
                        .lineLimit(1)
                    
                    if let name = user.name, !name.isEmpty {
                        Text(name)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(DesignSystem.Shadows.small)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("User \(user.login)")
        .accessibilityHint("Tap to view user repositories")
    }
}

#Preview {
    VStack(spacing: 16) {
        UserRowView(
            user: GitHubUser.mock
        ) {
            print("Tapped octocat")
        }
        
        UserRowView(
            user: GitHubUser(
                id: 2,
                login: "testuser",
                avatarURL: "",
                type: "User",
                siteAdmin: false,
                name: "Test User",
                bio: "A test user",
                followers: 100,
                following: 50,
                publicRepos: 25
            )
        ) {
            print("Tapped testuser")
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
