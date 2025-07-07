//
//  DependencyContainer.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

/// Dependency injection container for managing service dependencies
final class DependencyContainer: ObservableObject {
    
    lazy var router: Router = {
        return Router()
    }()
    
    // MARK: - Singleton
    static let shared = DependencyContainer()
    
    private init() {
        // Dependencies are initialized lazily
    }
} 
