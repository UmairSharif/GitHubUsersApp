//
//  UserListView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct UserListView: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @StateObject private var viewModel: UserListViewModel
    
    init() {
        // This will be properly initialized by the environment
        self._viewModel = StateObject(wrappedValue: UserListViewModel(
            gitHubService: DependencyContainer.shared.gitHubService,
            router: DependencyContainer.shared.router,
            favoritesService: DependencyContainer.shared.favoritesService
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(
                text: $viewModel.searchText,
                placeholder: "Search GitHub users...",
                onSearch: {
                    Task {
                        await viewModel.dismissSearchAndReload()
                    }
                }
            )
            
            if viewModel.isLoadingUsers && viewModel.users.isEmpty {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else if viewModel.shouldShowInitialState {
                initialStateView
            } else if viewModel.shouldShowEmptyState {
                emptyStateView
            } else {
                userListView
            }
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("GitHub Users")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dependencyContainer.router.navigate(to: .favorites)
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(DesignSystem.Colors.error)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dependencyContainer.router.navigate(to: .apiKeyConfig)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .task {
            await viewModel.loadUsers(isRefresh: false)
        }
        .refreshable {
            await viewModel.refreshUsers()
        }
        .keyboardDismiss {
            // Reload previous list if search was active
            if !viewModel.searchText.isEmpty {
                Task {
                    await viewModel.dismissSearchAndReload()
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading users...")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.error)
            
            Text("Something went wrong")
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
                    await viewModel.loadUsers(isRefresh: false)
                }
            }
            .primaryButtonStyle()
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var initialStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            
            Text("Discover GitHub Users")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            Text("Search for GitHub users to explore their repositories and contributions.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            
            Text("No users found")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            Text("Try adjusting your search terms or browse popular users.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var userListView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(viewModel.users) { user in
                    UserRowView(
                        user: user,
                        onTap: { viewModel.selectUser(user) },
                        isFavorite: viewModel.isFavorite(user),
                        onToggleFavorite: { viewModel.toggleFavorite(user) }
                    )
                    .onAppear {
                        Task {
                            await viewModel.loadMoreUsersIfNeeded(currentUser: user)
                        }
                    }
                }
                
                if viewModel.isLoadingUsers && !viewModel.users.isEmpty {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more users...")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

#Preview {
    NavigationStack {
        UserListView()
            .environmentObject(DependencyContainer.shared)
    }
} 
