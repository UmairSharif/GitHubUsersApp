//
//  DependencyContainer.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

/// Dependency injection container for managing service dependencies
final class DependencyContainer: ObservableObject {
    
    // MARK: - Services
    lazy var gitHubService: GitHubServiceProtocol = {
        return GitHubService()
    }()
    
    lazy var router: Router = {
        return Router()
    }()
    
    // MARK: - Singleton
    static let shared = DependencyContainer()
    
    private init() {
        // Dependencies are initialized lazily
    }
    
    // MARK: - Public Methods
    func setGitHubAPIKey(_ key: String) {
        GitHubAPIKeyManager.shared.setAPIKey(key)
    }
    
    func hasAPIKey() -> Bool {
        return GitHubAPIKeyManager.shared.hasAPIKey()
    }
    
    func getAPIKey() -> String? {
        return GitHubAPIKeyManager.shared.apiKey
    }
} 
