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
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
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
                
                BookmarkButton(
                    user: user,
                    isFavorite: isFavorite,
                    onToggle: onToggleFavorite
                )
                
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
            user: GitHubUser.mock,
            onTap: { print("Tapped octocat") },
            isFavorite: false,
            onToggleFavorite: { print("Toggle favorite") }
        )
        
        UserRowView(
            user: GitHubUser.mock,
            onTap: { print("Tapped testuser") },
            isFavorite: true,
            onToggleFavorite: { print("Toggle favorite") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
