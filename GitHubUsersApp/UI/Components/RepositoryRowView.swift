//
//  RepositoryRowView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct RepositoryRowView: View {
    let repository: GitHubRepository
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(repository.name)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.githubText)
                            .lineLimit(1)
                        
                       if let description = repository.description, !description.isEmpty {
                            Text(repository.displayDescription)
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                }
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    if !repository.displayLanguage.isEmpty {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Circle()
                                .fill(languageColor)
                                .frame(width: 8, height: 8)
                            
                            Text(repository.displayLanguage)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                        }
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        
                        Text("\(repository.stargazersCount)")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(DesignSystem.Shadows.small)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Repository \(repository.name)")
        .accessibilityHint("Tap to open repository in browser")
    }
    
    private var languageColor: Color {
        switch repository.displayLanguage.lowercased() {
        case "swift":
            return .orange
        case "javascript", "typescript":
            return .yellow
        case "python":
            return .blue
        case "java":
            return .red
        case "c++", "c#":
            return .purple
        case "go":
            return .cyan
        case "rust":
            return .orange
        case "kotlin":
            return .purple
        case "php":
            return .purple
        default:
            return DesignSystem.Colors.githubTextSecondary
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        RepositoryRowView(
            repository: GitHubRepository.mock
        ) {
            print("Tapped repository")
        }
        
        RepositoryRowView(
            repository: GitHubRepository.mock
        ) {
            print("Tapped test repository")
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
