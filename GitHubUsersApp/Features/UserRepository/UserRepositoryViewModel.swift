//
//  UserRepositoryViewModel.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import SwiftUI
import Combine
import os.log

@MainActor
final class UserRepositoryViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    @Published var user: GitHubUser
    @Published var repositories: [GitHubRepository] = []
    @Published var searchQuery: String = ""
    @Published var isRefreshing = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private State
    var isLoadingUserDetails = false
    var isLoadingRepositories = false
    
    // MARK: - Private Properties
    private let gitHubService: GitHubServiceProtocol
    private let router: any RouterProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let logger = Logger(subsystem: "com.githubusersapp.viewmodel", category: "UserRepositoryViewModel")
    
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Pagination
    private var _currentPage = 1
    private var _hasMorePages = true
    private let itemsPerPage = 20
    
    // MARK: - Initialization
    init(user: GitHubUser, gitHubService: GitHubServiceProtocol, router: any RouterProtocol, favoritesService: FavoritesServiceProtocol) {
        self.user = user
        self.gitHubService = gitHubService
        self.router = router
        self.favoritesService = favoritesService
        
        favoritesService.favoritesPublisher
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        logger.info("UserRepositoryViewModel initialized for user: \(user.login)")
    }
    
    // MARK: - Public Methods
    func loadUserDetails(isRefresh: Bool = false) async {
        guard !isLoadingUserDetails else { 
            logger.info("Skipping loadUserDetails - already loading user details")
            return 
        }
        
        logger.info("Loading user details for: \(self.user.login), isRefresh: \(isRefresh)")
        isLoadingUserDetails = true
        clearError()
        
        let result = await gitHubService.getUserDetails(username: user.login)
        
        switch result {
        case .success(let detailedUser):
            user = detailedUser
            logger.info("User details loaded successfully for: \(self.user.login)")
        case .failure(let error):
            logger.error("Failed to load user details: \(error.localizedDescription)")
            showError(error.localizedDescription)
        }
        
        isLoadingUserDetails = false
    }
    
    func loadRepositories(isRefresh: Bool = false) async {
        guard !isLoadingRepositories else { 
            logger.info("Skipping loadRepositories - already loading repositories")
            return 
        }
        
        // Reset pagination state if this is a refresh
        if isRefresh {
            _currentPage = 1
            _hasMorePages = true
            repositories.removeAll()
        }
        
        logger.info("Loading repositories for user: \(self.user.login), page: \(self._currentPage), isRefresh: \(isRefresh)")
        isLoadingRepositories = true
        clearError()
        
        let result = await gitHubService.getUserNonForkedRepositories(
            username: user.login,
            page: _currentPage,
            perPage: itemsPerPage
        )
        
        switch result {
        case .success(let repos):
            if _currentPage == 1 {
                repositories = repos
                logger.info("Loaded first page with \(repos.count) repositories")
            } else {
                repositories.append(contentsOf: repos)
                logger.info("Appended page \(self._currentPage) with \(repos.count) repositories. Total: \(self.repositories.count)")
            }
            
            // Update pagination state - continue loading if:
            // 1. We got results (repos.count > 0)
            // 2. We haven't reached the total repository count yet (safety check)
            let totalRepos = user.publicRepos ?? 0
            _hasMorePages = repos.count > 0 && repositories.count < totalRepos
            
            logger.info("Pagination state - repos.count: \(repos.count), totalLoaded: \(self.repositories.count), totalRepos: \(totalRepos), hasMorePages: \(self._hasMorePages)")
            _currentPage += 1
            
        case .failure(let error):
            logger.error("Failed to load repositories: \(error.localizedDescription)")
            showError(error.localizedDescription)
        }
        
        isLoadingRepositories = false
    }
    
    func refreshData() async {
        guard !isRefreshing else { 
            logger.info("Skipping refreshData - already refreshing")
            return 
        }
        
        logger.info("Refreshing data for user: \(self.user.login)")
        isRefreshing = true
        
        await loadUserDetails(isRefresh: true)
        await loadRepositories(isRefresh: true)
        
        isRefreshing = false
        logger.info("Refresh completed for user: \(self.user.login)")
    }
    
    func loadMoreRepositoriesIfNeeded(currentRepository repo: GitHubRepository) async {
        guard _hasMorePages && !isLoadingRepositories else { 
            logger.info("Skipping loadMoreRepositoriesIfNeeded - hasMorePages: \(self._hasMorePages), isLoadingRepositories: \(self.isLoadingRepositories)")
            return
        }
        
        // Ensure we have enough repositories to check threshold
        guard repositories.count > 5 else { 
            logger.info("Skipping loadMoreRepositoriesIfNeeded - not enough repositories (\(self.repositories.count))")
            return
        }
        
        // Ensure the repository still exists in our array
        guard let currentIndex = repositories.firstIndex(where: { $0.id == repo.id }) else { 
            logger.info("Skipping loadMoreRepositoriesIfNeeded - repository not found in array")
            return 
        }
        
        let thresholdOffset = 5
        let thresholdIndex = repositories.index(repositories.endIndex, offsetBy: -thresholdOffset)
        
        logger.info("Checking pagination threshold - currentIndex: \(currentIndex), thresholdIndex: \(thresholdIndex), totalRepos: \(self.repositories.count), hasMorePages: \(self._hasMorePages)")
        
        if currentIndex >= thresholdIndex {
            logger.info("Loading more repositories - reached threshold for repo: \(repo.name) at index \(currentIndex)")
            await loadRepositories(isRefresh: false)
        } else {
            logger.info("Not yet at threshold - currentIndex: \(currentIndex), thresholdIndex: \(thresholdIndex)")
        }
    }
    
    func selectRepository(_ repository: GitHubRepository) {
        logger.info("Repository selected: \(repository.name)")
        if let url = repository.repositoryURL {
            router.navigate(to: .repositoryWebView(url))
        } else {
            logger.error("Repository URL is nil for: \(repository.name)")
        }
    }
    
    func openRepository(_ repository: GitHubRepository) {
        selectRepository(repository)
    }
    
    // MARK: - Computed Properties
    var hasRepositories: Bool {
        !repositories.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoadingUserDetails && !isLoadingRepositories && !hasError && filteredRepositories.isEmpty
    }
    
    var repositoriesCount: Int {
        filteredRepositories.count
    }
    
    var totalRepositories: Int {
        user.publicRepos ?? 0
    }
    
    var isLoadingMore: Bool {
        isLoadingRepositories && !repositories.isEmpty
    }
    
    var hasMorePages: Bool {
        return self._hasMorePages
    }
    
    var currentPage: Int {
        return self._currentPage
    }
    
    // MARK: - Search Properties
    var filteredRepositories: [GitHubRepository] {
        guard !searchQuery.isEmpty else {
            return repositories
        }
        
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return repositories.filter { repository in
            
            if repository.name.lowercased().contains(query) {
                return true
            }
            
            if let description = repository.description?.lowercased(),
               description.contains(query) {
                return true
            }
            
            if let language = repository.language?.lowercased(),
               language.contains(query) {
                return true
            }
            
            if repository.fullName.lowercased().contains(query) {
                return true
            }
            
            return false
        }
    }
    
    var isSearching: Bool {
        !searchQuery.isEmpty
    }
    
    var searchResultsCount: Int {
        filteredRepositories.count
    }
    
    // MARK: - Search Methods
    func updateSearchQuery(_ query: String) {
        logger.info("Updating search query to: '\(query)'")
        searchQuery = query
    }
    
    func clearSearch() {
        logger.info("Clearing search query")
        searchQuery = ""
    }
    
    // MARK: - Favorites Methods
    func isFavorite() -> Bool {
        return favoritesService.isFavorite(self.user)
    }
    
    func toggleFavorite() {
        logger.info("Toggling favorite for user: \(self.user.login)")
        favoritesService.toggleFavorite(self.user)
    }
} 
