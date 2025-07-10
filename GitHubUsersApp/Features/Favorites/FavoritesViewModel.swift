//
//  FavoritesViewModel.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import SwiftUI
import Combine
import os.log

@MainActor
final class FavoritesViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    @Published var favorites: [GitHubUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var showingClearConfirmation = false
    
    // MARK: - Private Properties
    private let favoritesService: FavoritesServiceProtocol
    private let router: any RouterProtocol
    private let logger = Logger(subsystem: "com.githubusersapp.viewmodel", category: "FavoritesViewModel")
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(favoritesService: FavoritesServiceProtocol, router: any RouterProtocol) {
        self.favoritesService = favoritesService
        self.router = router
        setupBindings()
        logger.info("FavoritesViewModel initialized")
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Subscribe to favorites changes
        favoritesService.favoritesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                self?.favorites = favorites
                self?.logger.info("Favorites updated: \(favorites.count) items")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadFavorites() {
        logger.info("Loading favorites")
        isLoading = true
        clearError()
        
        // Simulate loading delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.favorites = self?.favoritesService.getFavorites() ?? []
            self?.isLoading = false
            self?.logger.info("Favorites loaded: \(self?.favorites.count ?? 0) items")
        }
    }
    
    func removeFromFavorites(_ user: GitHubUser) {
        logger.info("Removing user from favorites: \(user.login)")
        favoritesService.removeFromFavorites(user)
    }
    
    func selectUser(_ user: GitHubUser) {
        logger.info("User selected: \(user.login)")
        router.navigate(to: .userDetail(user))
    }
    
    func clearAllFavorites() {
        logger.info("Clearing all favorites")
        favoritesService.clearAllFavorites()
        showingClearConfirmation = false
    }
    
    func confirmClearAll() {
        showingClearConfirmation = true
    }
    
    func cancelClearAll() {
        showingClearConfirmation = false
    }
    
    // MARK: - Computed Properties
    var filteredFavorites: [GitHubUser] {
        if searchText.isEmpty {
            return favorites
        } else {
            return favorites.filter { user in
                user.login.localizedCaseInsensitiveContains(searchText) ||
                user.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var hasFavorites: Bool {
        return !favorites.isEmpty
    }
    
    var hasFilteredFavorites: Bool {
        return !filteredFavorites.isEmpty
    }
    
    var favoritesCount: Int {
        return favorites.count
    }
    
    var shouldShowEmptyState: Bool {
        return !isLoading && !hasFavorites && !hasError
    }
    
    var shouldShowEmptySearchState: Bool {
        return !isLoading && !searchText.isEmpty && !hasFilteredFavorites && !hasError
    }
} 