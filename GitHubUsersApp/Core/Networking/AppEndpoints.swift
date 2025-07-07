//
//  AppEndpoints.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

enum AppEndpoints {
    case searchUsers(query: String, page: Int, perPage: Int)
    case getUserDetails(username: String)
    case getUserRepositories(username: String, page: Int, perPage: Int)
    case getUserNonForkedRepositories(username: String, page: Int, perPage: Int)
}

extension AppEndpoints: Endpoint {
    
    var baseUrl: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .searchUsers:
            return "/search/users"
        case .getUserDetails(let username):
            return "/users/\(username)"
        case .getUserRepositories(let username), .getUserNonForkedRepositories(let username):
            return "/users/\(username.0)/repos"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .searchUsers, .getUserDetails, .getUserRepositories, .getUserNonForkedRepositories:
            return .get
        }
    }
    
    var header: [String : String]? {
        var headers = [
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "GitHubUsersApp/1.0"
        ]
        
        // Add API key if available
        if let apiKey = GitHubAPIKeyManager.shared.apiKey {
            headers["Authorization"] = "token \(apiKey)"
        }
        
        return headers
    }
    
    var query: [String : Any]? {
        switch self {
        case .searchUsers(let query, let page, let perPage):
            return [
                "q": query,
                "page": page,
                "per_page": perPage
            ]
        case .getUserDetails:
            return nil
        case .getUserRepositories(_, let page, let perPage):
            return [
                "page": page,
                "per_page": perPage,
                "sort": "updated",
                "direction": "desc"
            ]
        case .getUserNonForkedRepositories(_, let page, let perPage):
            return [
                "page": page,
                "per_page": perPage,
                "sort": "updated",
                "direction": "desc",
                "type": "owner"
            ]
        }
    }
    
    var body: Codable? {
        return nil
    }
    
    var fileName: String? {
        return nil
    }
    
    var mimeType: String? {
        return nil
    }
}

// MARK: - API Key Manager
final class GitHubAPIKeyManager {
    static let shared = GitHubAPIKeyManager()
    
    private init() {}
    
    var apiKey: String? {
        // Try to load from environment variable first (for production)
        if let envKey = ProcessInfo.processInfo.environment["GITHUB_API_KEY"] {
            return envKey
        }
        
        // Try to load from UserDefaults (for development)
        if let savedKey = UserDefaults.standard.string(forKey: "GitHubAPIKey") {
            return savedKey
        }
        
        return nil
    }
    
    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "GitHubAPIKey")
    }
    
    func removeAPIKey() {
        UserDefaults.standard.removeObject(forKey: "GitHubAPIKey")
    }
    
    func hasAPIKey() -> Bool {
        return apiKey != nil
    }
}
