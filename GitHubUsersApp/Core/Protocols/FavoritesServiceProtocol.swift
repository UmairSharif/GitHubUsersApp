//
//  FavoritesServiceProtocol.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import Combine

/// Protocol defining favorites management capabilities
protocol FavoritesServiceProtocol {
    /// Publisher for favorites changes
    var favoritesPublisher: AnyPublisher<[GitHubUser], Never> { get }
    
    /// Get all favorite users
    func getFavorites() -> [GitHubUser]
    
    /// Add a user to favorites
    /// - Parameter user: The user to add to favorites
    func addToFavorites(_ user: GitHubUser)
    
    /// Remove a user from favorites
    /// - Parameter user: The user to remove from favorites
    func removeFromFavorites(_ user: GitHubUser)
    
    /// Check if a user is in favorites
    /// - Parameter user: The user to check
    /// - Returns: True if user is in favorites, false otherwise
    func isFavorite(_ user: GitHubUser) -> Bool
    
    /// Toggle favorite status of a user
    /// - Parameter user: The user to toggle favorite status for
    func toggleFavorite(_ user: GitHubUser)
    
    /// Clear all favorites
    func clearAllFavorites()
    
    /// Get favorites count
    var favoritesCount: Int { get }
} 