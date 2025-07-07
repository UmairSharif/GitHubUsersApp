//
//  UserAvatarView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct UserAvatarView: View {
    let imageURL: URL?
    let size: CGFloat
    let username: String
    
    init(imageURL: URL?, size: CGFloat = 40, username: String) {
        self.imageURL = imageURL
        self.size = size
        self.username = username
    }
    
    var body: some View {
        Group {
            if let imageURL = imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure:
                        fallbackAvatar
                    @unknown default:
                        fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: size, height: size)
    }
    
    private var fallbackAvatar: some View {
        Circle()
            .fill(DesignSystem.Colors.githubBorder)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            )
    }
    
    private var initials: String {
        let components = username.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(username.prefix(2)).uppercased()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        UserAvatarView(
            imageURL: URL(string: "https://avatars.githubusercontent.com/u/1?v=4"),
            size: 60,
            username: "octocat"
        )
        
        UserAvatarView(
            imageURL: nil,
            size: 60,
            username: "John Doe"
        )
        
        UserAvatarView(
            imageURL: nil,
            size: 40,
            username: "test"
        )
    }
    .padding()
} 