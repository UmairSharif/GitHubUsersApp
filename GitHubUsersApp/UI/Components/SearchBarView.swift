//
//  SearchBarView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                
                TextField(placeholder, text: $text)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.githubText)
                    .focused($isFocused)
                    .onSubmit {
                        onSearch()
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isFocused = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.githubBorder, lineWidth: 1)
            )
            
            if !text.isEmpty {
                Button("Search") {
                    onSearch()
                    isFocused = false
                }
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBarView(
            text: .constant(""),
            placeholder: "Search GitHub users..."
        ) {
            print("Search tapped")
        }
        
        SearchBarView(
            text: .constant("octocat"),
            placeholder: "Search GitHub users..."
        ) {
            print("Search tapped")
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 