//
//  FavoritesService.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import Combine
import os.log

/// Concrete implementation of FavoritesServiceProtocol using UserDefaults for persistence
final class FavoritesService: FavoritesServiceProtocol {
    
    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let favoritesKey = "GitHubUsersFavorites"
    private let logger = Logger(subsystem: "com.githubusersapp.service", category: "FavoritesService")
    
    // MARK: - Published Properties
    private let favoritesSubject = CurrentValueSubject<[GitHubUser], Never>([])
    
    var favoritesPublisher: AnyPublisher<[GitHubUser], Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadFavorites()
        logger.info("FavoritesService initialized with \(self.favoritesCount) favorites")
    }
    
    // MARK: - Public Methods
    func getFavorites() -> [GitHubUser] {
        return favoritesSubject.value
    }
    
    func addToFavorites(_ user: GitHubUser) {
        var favorites = favoritesSubject.value
        
        // Check if user is already in favorites
        guard !favorites.contains(where: { $0.id == user.id }) else {
            logger.info("User \(user.login) is already in favorites")
            return
        }
        
        favorites.append(user)
        saveFavorites(favorites)
        logger.info("Added user \(user.login) to favorites. Total favorites: \(favorites.count)")
    }
    
    func removeFromFavorites(_ user: GitHubUser) {
        var favorites = favoritesSubject.value
        
        if let index = favorites.firstIndex(where: { $0.id == user.id }) {
            favorites.remove(at: index)
            saveFavorites(favorites)
            logger.info("Removed user \(user.login) from favorites. Total favorites: \(favorites.count)")
        } else {
            logger.info("User \(user.login) was not found in favorites")
        }
    }
    
    func isFavorite(_ user: GitHubUser) -> Bool {
        return favoritesSubject.value.contains(where: { $0.id == user.id })
    }
    
    func toggleFavorite(_ user: GitHubUser) {
        if isFavorite(user) {
            removeFromFavorites(user)
        } else {
            addToFavorites(user)
        }
    }
    
    func clearAllFavorites() {
        saveFavorites([])
        logger.info("Cleared all favorites")
    }
    
    var favoritesCount: Int {
        return favoritesSubject.value.count
    }
    
    // MARK: - Private Methods
    private func loadFavorites() {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            logger.info("No favorites data found in UserDefaults")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let favorites = try decoder.decode([GitHubUser].self, from: data)
            favoritesSubject.send(favorites)
            logger.info("Loaded \(favorites.count) favorites from UserDefaults")
        } catch {
            logger.error("Failed to decode favorites from UserDefaults: \(error.localizedDescription)")
            // Clear corrupted data
            userDefaults.removeObject(forKey: favoritesKey)
        }
    }
    
    private func saveFavorites(_ favorites: [GitHubUser]) {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(favorites)
            userDefaults.set(data, forKey: favoritesKey)
            favoritesSubject.send(favorites)
            logger.info("Saved \(favorites.count) favorites to UserDefaults")
        } catch {
            logger.error("Failed to encode favorites to UserDefaults: \(error.localizedDescription)")
        }
    }
} 