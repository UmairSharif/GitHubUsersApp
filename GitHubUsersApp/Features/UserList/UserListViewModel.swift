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
    @Published var searchText = ""
    @Published var isRefreshing = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private State
    var isLoadingUsers = false
    
    // MARK: - Private Properties
    private let gitHubService: GitHubServiceProtocol
    private let router: Router
    private let logger = Logger(subsystem: "com.githubusersapp.viewmodel", category: "UserListViewModel")
    
    // MARK: - Task Management
    private var currentLoadTask: Task<Void, Never>?
    
    // MARK: - Pagination
    private var currentPage = 1
    private var hasMorePages = true
    private let itemsPerPage = 20
    
    // MARK: - Initialization
    init(gitHubService: GitHubServiceProtocol, router: Router) {
        self.gitHubService = gitHubService
        self.router = router
        logger.info("UserListViewModel initialized")
    }
    
    // MARK: - Public Methods
    func loadUsers(isRefresh: Bool = false) async {
        // Cancel any existing load task
        currentLoadTask?.cancel()
        
        // Create new task for loading users
        currentLoadTask = Task {
            guard !isLoadingUsers else { 
                logger.info("Skipping loadUsers - already loading users")
                return 
            }
            
            logger.info("Loading users - page: \(self.currentPage), searchText: '\(self.searchText)', isRefresh: \(isRefresh)")
            isLoadingUsers = true
            clearError()
            
            let result = await gitHubService.searchUsers(
                query: searchText.isEmpty ? "a" : searchText,
                page: currentPage,
                perPage: itemsPerPage
            )
            
            // Check if task was cancelled
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
        // Cancel any existing tasks
        currentLoadTask?.cancel()
        
        logger.info("Searching users with query: '\(self.searchText)'")
        currentPage = 1
        hasMorePages = true
        users.removeAll()
        await loadUsers(isRefresh: false)
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
        let thresholdIndex = users.index(users.endIndex, offsetBy: -5)
        if users.firstIndex(where: { $0.id == user.id }) == thresholdIndex {
            logger.info("Loading more users - reached threshold for user: \(user.login)")
            await loadUsers(isRefresh: false)
        }
    }
    
    func selectUser(_ user: GitHubUser) {
        logger.info("User selected: \(user.login)")
        router.navigate(to: .userDetail(user))
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
