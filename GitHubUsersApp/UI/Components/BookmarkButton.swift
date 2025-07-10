//
//  BookmarkButton.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct BookmarkButton: View {
    let user: GitHubUser
    let isFavorite: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFavorite ? DesignSystem.Colors.error : DesignSystem.Colors.textSecondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Tap to \(isFavorite ? "remove" : "add") \(user.login) \(isFavorite ? "from" : "to") favorites")
    }
}

#Preview {
    VStack(spacing: 20) {
        BookmarkButton(
            user: GitHubUser.mock,
            isFavorite: false,
            onToggle: { print("Toggle favorite") }
        )
        
        BookmarkButton(
            user: GitHubUser.mock,
            isFavorite: true,
            onToggle: { print("Toggle favorite") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 
