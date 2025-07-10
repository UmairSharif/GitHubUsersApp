//
//  UserRepositoryViewModel.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import SwiftUI
import os.log

@MainActor
final class UserRepositoryViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    @Published var user: GitHubUser
    @Published var repositories: [GitHubRepository] = []
    @Published var isRefreshing = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private State
    var isLoadingUserDetails = false
    var isLoadingRepositories = false
    
    // MARK: - Private Properties
    private let gitHubService: GitHubServiceProtocol
    private let router: any RouterProtocol
    private let logger = Logger(subsystem: "com.githubusersapp.viewmodel", category: "UserRepositoryViewModel")
    
    // MARK: - Pagination
    private var currentPage = 1
    private var hasMorePages = true
    private let itemsPerPage = 20
    
    // MARK: - Initialization
    init(user: GitHubUser, gitHubService: GitHubServiceProtocol, router: any RouterProtocol) {
        self.user = user
        self.gitHubService = gitHubService
        self.router = router
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
        
        logger.info("Loading repositories for user: \(self.user.login), page: \(self.currentPage), isRefresh: \(isRefresh)")
        isLoadingRepositories = true
        clearError()
        
        let result = await gitHubService.getUserNonForkedRepositories(
            username: user.login,
            page: currentPage,
            perPage: itemsPerPage
        )
        
        switch result {
        case .success(let repos):
            if currentPage == 1 {
                repositories = repos
                logger.info("Loaded first page with \(repos.count) repositories")
            } else {
                repositories.append(contentsOf: repos)
                logger.info("Appended page \(self.currentPage) with \(repos.count) repositories. Total: \(self.repositories.count)")
            }
            
            hasMorePages = repos.count == itemsPerPage
            currentPage += 1
            
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
        currentPage = 1
        hasMorePages = true
        repositories.removeAll()
        
        await loadUserDetails(isRefresh: true)
        await loadRepositories(isRefresh: true)
        
        isRefreshing = false
        logger.info("Refresh completed for user: \(self.user.login)")
    }
    
    func loadMoreRepositoriesIfNeeded(currentRepository repo: GitHubRepository) async {
        guard hasMorePages else { return }
        
        // Ensure we have enough repositories to check threshold
        guard repositories.count > 5 else { return }
        
        // Ensure the repository still exists in our array
        guard let currentIndex = repositories.firstIndex(where: { $0.id == repo.id }) else { return }
        
        let thresholdOffset = 5
        let thresholdIndex = repositories.index(repositories.endIndex, offsetBy: -thresholdOffset)
        
        if currentIndex >= thresholdIndex {
            logger.info("Loading more repositories - reached threshold for repo: \(repo.name)")
            await loadRepositories(isRefresh: false)
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
        !isLoadingUserDetails && !isLoadingRepositories && !hasError && repositories.isEmpty
    }
    
    var repositoriesCount: Int {
        repositories.count
    }
    
    var totalRepositories: Int {
        user.publicRepos ?? 0
    }
} 
