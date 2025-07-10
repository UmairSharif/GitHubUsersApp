//
//  UserRepositoryView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI
import os.log

struct UserRepositoryView: View {
    let user: GitHubUser
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @StateObject private var viewModel: UserRepositoryViewModel
    private let logger = Logger(subsystem: "com.githubusersapp.view", category: "UserRepositoryView")
    
    init(user: GitHubUser) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: UserRepositoryViewModel(
            user: user,
            gitHubService: DependencyContainer.shared.gitHubService,
            router: DependencyContainer.shared.router,
            favoritesService: DependencyContainer.shared.favoritesService
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                UserProfileHeaderView(
                    user: viewModel.user,
                    isFavorite: viewModel.isFavorite(),
                    onToggleFavorite: { viewModel.toggleFavorite() }
                )
                
                if (viewModel.isLoadingUserDetails || viewModel.isLoadingRepositories) && viewModel.repositories.isEmpty {
                    loadingView
                } else if viewModel.hasError {
                    errorView
                } else if viewModel.shouldShowEmptyState {
                    emptyStateView
                } else {
                    repositoriesView
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle(viewModel.user.login)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadUserDetails(isRefresh: false)
            await viewModel.loadRepositories(isRefresh: false)
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading repositories...")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var errorView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.error)
            
            Text("Failed to load repositories")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Try Again") {
                Task {
                    await viewModel.loadRepositories(isRefresh: false)
                }
            }
            .primaryButtonStyle()
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: viewModel.isSearching ? "magnifyingglass" : "folder")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            
            Text(viewModel.isSearching ? "No search results" : "No repositories found")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            Text(viewModel.isSearching ? 
                 "No repositories match your search query '\(viewModel.searchQuery)'" :
                 "This user doesn't have any public repositories yet.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                .multilineTextAlignment(.center)
            
            if viewModel.isSearching {
                Button("Clear Search") {
                    viewModel.clearSearch()
                }
                .primaryButtonStyle()
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var repositoriesView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Repositories")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.githubText)
                
                Spacer()
                
                if viewModel.isSearching {
                    Text("\(viewModel.searchResultsCount) of \(viewModel.repositories.count)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                } else {
                    Text("\(viewModel.repositoriesCount) of \(viewModel.totalRepositories)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                }
            }
            
            // Search Bar
            SearchBarView(
                text: $viewModel.searchQuery,
                placeholder: "Search repositories...",
                onSearch: nil
            )
            

            
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(Array(viewModel.filteredRepositories.enumerated()), id: \.element.id) { index, repository in
                    RepositoryRowView(repository: repository) {
                        viewModel.selectRepository(repository)
                    }
                    .onAppear {
                        Task {
                            logger.info("Repository appeared: \(repository.name) at index \(index)")
                            if !viewModel.isSearching {
                                await viewModel.loadMoreRepositoriesIfNeeded(currentRepository: repository)
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingMore && !viewModel.isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more repositories...")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserRepositoryView(
            user: GitHubUser.mock
        )
        .environmentObject(DependencyContainer.shared)
    }
}
