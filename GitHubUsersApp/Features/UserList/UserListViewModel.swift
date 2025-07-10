//
//  UserListViewModel.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import SwiftUI
import os.log

@MainActor
final class UserListViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var users: [GitHubUser] = []
    @Published var searchText = "" {
        didSet {
            handleSearchTextChange()
        }
    }
    @Published var isRefreshing = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private State
    var isLoadingUsers = false
    
    // MARK: - Private Properties
    private let gitHubService: GitHubServiceProtocol
    private let router: any RouterProtocol
    private let logger = Logger(subsystem: "com.githubusersapp.viewmodel", category: "UserListViewModel")
    
    // MARK: - Task Management
    private var currentLoadTask: Task<Void, Never>?
    private var searchThrottleTask: Task<Void, Never>?
    
    // MARK: - Pagination
    private var currentPage = 1
    private var hasMorePages = true
    private let itemsPerPage = 20
    
    // MARK: - Search State
    private var previousUsers: [GitHubUser] = []
    private var previousPage = 1
    private var previousHasMorePages = true
    private var isSearchMode = false
    
    // MARK: - Initialization
    init(gitHubService: GitHubServiceProtocol, router: any RouterProtocol) {
        self.gitHubService = gitHubService
        self.router = router
        logger.info("UserListViewModel initialized")
    }
    
    // MARK: - Private Methods
    private func handleSearchTextChange() {
        searchThrottleTask?.cancel()
        
        if searchText.isEmpty {
            if isSearchMode {
                restorePreviousState()
            } else {
                clearError()
            }
        } else {
            searchThrottleTask = Task {
                try? await Task.sleep(nanoseconds: 0_500_000_000) // 0.5 seconds
                
                guard !Task.isCancelled else { return }
                
                await performSearch()
            }
        }
    }
    
    private func restorePreviousState() {
        logger.info("Restoring previous state - users: \(self.previousUsers.count), page: \(self.previousPage)")
        users = previousUsers
        currentPage = previousPage
        hasMorePages = previousHasMorePages
        isSearchMode = false
        clearError()
    }
    
    private func saveCurrentState() {
        if !isSearchMode {
            logger.info("Saving current state - users: \(self.users.count), page: \(self.currentPage)")
            previousUsers = users
            previousPage = currentPage
            previousHasMorePages = hasMorePages
        }
    }
    
    private func performSearch() async {
        currentLoadTask?.cancel()
        isLoadingUsers = false
        
        saveCurrentState()
        
        isLoadingUsers = true
        
        // Create new task for searching users
        currentLoadTask = Task {
            logger.info("Performing search with query: '\(self.searchText)'")
            clearError()
            isSearchMode = true
            
            // Reset pagination for search
            currentPage = 1
            hasMorePages = true
            users.removeAll()
            
            let result = await gitHubService.searchUsers(
                query: searchText,
                page: currentPage,
                perPage: itemsPerPage
            )
            
            // Check if task was cancelled
            guard !Task.isCancelled else {
                logger.info("performSearch task was cancelled")
                isLoadingUsers = false
                return
            }
            
            switch result {
            case .success(let response):
                users = response.items
                logger.info("Search completed with \(response.items.count) users")
                
                hasMorePages = response.items.count == itemsPerPage
                currentPage += 1
                
            case .failure(let error):
                // Don't show cancelled errors to the user
                if case .cancelled = error {
                    logger.info("Search request was cancelled, not showing error to user")
                    return
                }
                
                logger.error("Failed to search users: \(error.localizedDescription)")
                showError(error.localizedDescription)
            }
            
            isLoadingUsers = false
            logger.info("performSearch completed. isLoadingUsers: \(self.isLoadingUsers), hasError: \(self.hasError)")
        }
        
        await currentLoadTask?.value
    }
    
    // MARK: - Public Methods
    func loadUsers(isRefresh: Bool = false) async {
        guard !isLoadingUsers else { 
            logger.info("Skipping loadUsers - already loading users")
            return 
        }
        
        isLoadingUsers = true
        
        currentLoadTask?.cancel()
        
        currentLoadTask = Task {
            logger.info("Loading users - page: \(self.currentPage), searchText: '\(self.searchText)', isRefresh: \(isRefresh)")
            clearError()
            
            let result = await gitHubService.searchUsers(
                query: searchText.isEmpty ? "a" : searchText,
                page: currentPage,
                perPage: itemsPerPage
            )
            
            guard !Task.isCancelled else {
                logger.info("loadUsers task was cancelled")
                isLoadingUsers = false
                return
            }
            
            switch result {
            case .success(let response):
                if currentPage == 1 {
                    users = response.items
                    logger.info("Loaded first page with \(response.items.count) users")
                } else {
                    users.append(contentsOf: response.items)
                    logger.info("Appended page \(self.currentPage) with \(response.items.count) users. Total: \(self.users.count)")
                }
                
                hasMorePages = response.items.count == itemsPerPage
                currentPage += 1
                
            case .failure(let error):
                // Don't show cancelled errors to the user
                if case .cancelled = error {
                    logger.info("Request was cancelled, not showing error to user")
                    return
                }
                
                logger.error("Failed to load users: \(error.localizedDescription)")
                showError(error.localizedDescription)
            }
            
            isLoadingUsers = false
            logger.info("loadUsers completed. isLoadingUsers: \(self.isLoadingUsers), hasError: \(self.hasError)")
        }
        
        await currentLoadTask?.value
    }
    
    func searchUsers() async {
        currentLoadTask?.cancel()
        searchThrottleTask?.cancel()
        
        logger.info("Manual search triggered with query: '\(self.searchText)'")
        await performSearch()
    }
    
    func refreshUsers() async {
        logger.info("Refreshing users")
        isRefreshing = true
        currentPage = 1
        hasMorePages = true
        users.removeAll()
        
        // Use the existing loadUsers method which has proper guards
        await loadUsers(isRefresh: true)
        
        isRefreshing = false
        logger.info("refreshUsers completed. isRefreshing: \(self.isRefreshing)")
    }
    
    func loadMoreUsersIfNeeded(currentUser user: GitHubUser) async {
        // Ensure we have enough users to check threshold
        guard users.count > 5 else { return }
        
        // Ensure the user still exists in our array
        guard let currentIndex = users.firstIndex(where: { $0.id == user.id }) else { return }
        
        let thresholdIndex = users.index(users.endIndex, offsetBy: -5)
        if currentIndex == thresholdIndex {
            logger.info("Loading more users - reached threshold for user: \(user.login)")
            await loadUsers(isRefresh: false)
        }
    }
    
    func selectUser(_ user: GitHubUser) {
        logger.info("User selected: \(user.login)")
        router.navigate(to: .userDetail(user))
    }
    
    func dismissSearchAndReload() async {
        logger.info("Dismissing search and reloading previous list")
        searchText = ""
        await loadUsers(isRefresh: false)
    }
    
    // MARK: - Computed Properties
    var hasUsers: Bool {
        !users.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoadingUsers && !hasError && users.isEmpty && !searchText.isEmpty
    }
    
    var shouldShowInitialState: Bool {
        !isLoadingUsers && !hasError && users.isEmpty && searchText.isEmpty
    }
} 
