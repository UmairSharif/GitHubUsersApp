//
//  GitHubModels.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

// MARK: - User Models
struct GitHubUser: Codable, Identifiable, Hashable {
    let id: Int
    let login: String
    let avatarUrl: String
    let type: String
    let siteAdmin: Bool
    
    // Additional fields for user details
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let bio: String?
    let publicRepos: Int?
    let publicGists: Int?
    let followers: Int?
    let following: Int?
    let createdAt: String?
    let updatedAt: String?
    
    // Computed properties
    var displayName: String {
        return name ?? login
    }
    
    var avatarURL: URL? {
        guard let url = URL(string: avatarUrl),
              let scheme = url.scheme,
              (scheme == "http" || scheme == "https") else {
            return nil
        }
        return url
    }
    
    init(
        id: Int,
        login: String,
        avatarUrl: String,
        type: String,
        siteAdmin: Bool,
        name: String? = nil,
        company: String? = nil,
        blog: String? = nil,
        location: String? = nil,
        email: String? = nil,
        bio: String? = nil,
        publicRepos: Int? = nil,
        publicGists: Int? = nil,
        followers: Int? = nil,
        following: Int? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.type = type
        self.siteAdmin = siteAdmin
        self.name = name
        self.company = company
        self.blog = blog
        self.location = location
        self.email = email
        self.bio = bio
        self.publicRepos = publicRepos
        self.publicGists = publicGists
        self.followers = followers
        self.following = following
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension GitHubUser {
    static var mock: GitHubUser {
        GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false
        )
    }
}

// MARK: - Repository Models
struct GitHubRepository: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let size: Int
    let defaultBranch: String
    let visibility: String
    let fork: Bool
    let htmlUrl: String
    let cloneUrl: String
    let createdAt: String
    let updatedAt: String
    let pushedAt: String?
    
    let owner: GitHubUser
    
    var repositoryURL: URL? {
        guard let url = URL(string: htmlUrl),
              let scheme = url.scheme,
              (scheme == "http" || scheme == "https") else {
            return nil
        }
        return url
    }
    
    var displayLanguage: String {
        return language ?? "Unknown"
    }
    
    var displayDescription: String {
        return description ?? "No description available"
    }
}

// MARK: - API Response Models
struct SearchResponse<T: Codable>: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [T]
}

// MARK: - Error Response Model
struct GitHubErrorResponse: Codable {
    let message: String
    let documentationUrl: String?
}

// MARK: - Rate Limit Models
struct RateLimitInfo {
    let limit: Int
    let remaining: Int
    let reset: Date
    
    var isExceeded: Bool {
        return remaining <= 0
    }
    
    var resetTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: reset)
    }
}

extension GitHubRepository {
    static var mock: GitHubRepository {
        GitHubRepository(
            id: 1,
            name: "awesome-swift",
            fullName: "octocat/awesome-swift",
            description: "A curated list of awesome Swift libraries and resources",
            language: "Swift",
            stargazersCount: 1234,
            forksCount: 567,
            openIssuesCount: 10,
            size: 1024,
            defaultBranch: "main",
            visibility: "public",
            fork: false,
            htmlUrl: "https://github.com/octocat/awesome-swift",
            cloneUrl: "https://github.com/octocat/awesome-swift.git",
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z",
            pushedAt: "2023-01-01T00:00:00Z",
            owner: GitHubUser.mock
        )
    }
}
