//
//  GitHubModels.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

// MARK: - User Models
struct GitHubUser: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarURL: String?
    let type: String
    let siteAdmin: Bool
    let name: String?
    let bio: String?
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
    
    var displayName: String {
        return name ?? login
    }
    
    var avatarURLValue: URL? {
        guard let avatarURL = avatarURL else { return nil }
        return URL(string: avatarURL)
    }
    
    // Mock data for static design
    static let mock = GitHubUser(
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
    )
}

// MARK: - Repository Models
struct GitHubRepository: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let htmlURL: String
    
    var displayDescription: String {
        return description ?? "No description available"
    }
    
    var displayLanguage: String {
        return language ?? "Unknown"
    }
    
    // Mock data for static design
    static let mock = GitHubRepository(
        id: 1,
        name: "awesome-project",
        description: "An awesome project with amazing features and great documentation",
        language: "Swift",
        stargazersCount: 1234,
        htmlURL: "https://github.com/octocat/awesome-project"
    )
}
