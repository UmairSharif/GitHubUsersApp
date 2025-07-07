//
//  UserProfileHeaderView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct UserProfileHeaderView: View {
    let user: GitHubUser
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            UserAvatarView(
                imageURL: user.avatarURL,
                size: 80,
                username: user.login
            )
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(user.displayName)
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.githubText)
                    .multilineTextAlignment(.center)
                
                Text("@\(user.login)")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                
                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.githubText)
                        .multilineTextAlignment(.center)
                        .padding(.top, DesignSystem.Spacing.xs)
                }
            }
            
            HStack(spacing: DesignSystem.Spacing.xl) {
                StatView(
                    title: "Followers",
                    value: user.followers ?? 0,
                    icon: "person.2.fill"
                )
                
                StatView(
                    title: "Following",
                    value: user.following ?? 0,
                    icon: "person.2"
                )
                
                StatView(
                    title: "Repos",
                    value: user.publicRepos ?? 0,
                    icon: "folder.fill"
                )
            }
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .shadow(DesignSystem.Shadows.medium)
    }
}

struct StatView: View {
    let title: String
    let value: Int
    let icon: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("\(value)")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.githubText)
            }
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
        }
    }
}

//#Preview {
//    ScrollView {
//        VStack(spacing: 20) {
//            UserProfileHeaderView(
//                user: GitHubUser(
//                    id: 1,
//                    login: "octocat",
//                    avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
//                    type: "User",
//                    siteAdmin: false,
//                    name: "The Octocat",
//                    bio: "GitHub's mascot and octocat extraordinaire! 🐙"
//                )
//            )
//            
//            UserProfileHeaderView(
//                user: GitHubUser(
//                    id: 2,
//                    login: "testuser",
//                    avatarUrl: "",
//                    type: "User",
//                    siteAdmin: false,
//                    name: "Test User",
//                    bio: "A test user for development purposes"
//                )
//            )
//        }
//        .padding()
//    }
//    .background(DesignSystem.Colors.background)
//} 
