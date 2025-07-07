//
//  UserRepositoryView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct UserRepositoryView: View {
    let user: GitHubUser
    
    // Static mock data for design
    private let mockRepositories = [
        GitHubRepository(
            id: 1,
            name: "awesome-project",
            description: "An awesome project with amazing features and great documentation. This repository showcases best practices in software development.",
            language: "Swift",
            stargazersCount: 1234,
            htmlURL: "https://github.com/octocat/awesome-project"
        ),
        GitHubRepository(
            id: 2,
            name: "mobile-app",
            description: "A beautiful mobile application built with modern technologies and clean architecture patterns.",
            language: "Swift",
            stargazersCount: 567,
            htmlURL: "https://github.com/octocat/mobile-app"
        ),
        GitHubRepository(
            id: 3,
            name: "web-framework",
            description: "Lightweight and fast web framework for building scalable applications.",
            language: "JavaScript",
            stargazersCount: 890,
            htmlURL: "https://github.com/octocat/web-framework"
        ),
        GitHubRepository(
            id: 4,
            name: "data-science-tools",
            description: "Collection of tools and utilities for data science and machine learning projects.",
            language: "Python",
            stargazersCount: 432,
            htmlURL: "https://github.com/octocat/data-science-tools"
        ),
        GitHubRepository(
            id: 5,
            name: "api-gateway",
            description: "High-performance API gateway with authentication, rate limiting, and monitoring capabilities.",
            language: "Go",
            stargazersCount: 765,
            htmlURL: "https://github.com/octocat/api-gateway"
        ),
        GitHubRepository(
            id: 6,
            name: "design-system",
            description: "Comprehensive design system with reusable components and design tokens.",
            language: "TypeScript",
            stargazersCount: 321,
            htmlURL: "https://github.com/octocat/design-system"
        ),
        GitHubRepository(
            id: 7,
            name: "blockchain-wallet",
            description: "Secure and user-friendly blockchain wallet with multi-currency support.",
            language: "Rust",
            stargazersCount: 654,
            htmlURL: "https://github.com/octocat/blockchain-wallet"
        ),
        GitHubRepository(
            id: 8,
            name: "ai-chatbot",
            description: "Intelligent chatbot powered by machine learning with natural language processing capabilities.",
            language: "Python",
            stargazersCount: 987,
            htmlURL: "https://github.com/octocat/ai-chatbot"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                UserProfileHeaderView(user: user)
                
                repositoriesView
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle(user.login)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var repositoriesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Repositories")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.githubText)
                
                Spacer()
                
                Text("\(mockRepositories.count) repositories")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            }
            
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(mockRepositories) { repository in
                    RepositoryRowView(repository: repository) {
                        print("Selected repository: \(repository.name)")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserRepositoryView(
            user: GitHubUser.mock
        )
    }
}
