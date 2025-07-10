//
//  FavoritesView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @StateObject private var viewModel: FavoritesViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: FavoritesViewModel(
            favoritesService: DependencyContainer.shared.favoritesService,
            router: DependencyContainer.shared.router
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.hasFavorites {
                SearchBarView(
                    text: $viewModel.searchText,
                    placeholder: "Search favorites...",
                    onSearch: { }
                )
            }
            
            if viewModel.isLoading {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else if viewModel.shouldShowEmptyState {
                emptyStateView
            } else if viewModel.shouldShowEmptySearchState {
                emptySearchStateView
            } else {
                favoritesListView
            }
        }
        .background(DesignSystem.Colors.background)
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.hasFavorites {
                    Button("Clear All") {
                        viewModel.confirmClearAll()
                    }
                    .foregroundColor(DesignSystem.Colors.error)
                }
            }
        }
        .confirmationDialog(
            "Clear All Favorites",
            isPresented: $viewModel.showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                viewModel.clearAllFavorites()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelClearAll()
            }
        } message: {
            Text("This will remove all \(viewModel.favoritesCount) favorites. This action cannot be undone.")
        }
        .task {
            viewModel.loadFavorites()
        }
    }
    
    // MARK: - View Components
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading favorites...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var errorView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.error)
            
            Text("Error Loading Favorites")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            Button("Try Again") {
                viewModel.loadFavorites()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "heart.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("No Favorites Yet")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("Users you bookmark will appear here.\nStart by searching for users and tap the heart icon to add them to your favorites.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var emptySearchStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("No Results Found")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("No favorites match '\(viewModel.searchText)'")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
    
    private var favoritesListView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(viewModel.filteredFavorites) { user in
                    FavoriteUserRowView(
                        user: user,
                        onTap: { viewModel.selectUser(user) },
                        onRemove: { viewModel.removeFromFavorites(user) }
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Favorite User Row View
struct FavoriteUserRowView: View {
    let user: GitHubUser
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            UserAvatarView(
                imageURL: user.avatarURL,
                size: 48,
                username: user.login
            )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(user.displayName)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                    .lineLimit(1)
                
                Text("@\(user.login)")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineLimit(1)
                
                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.error)
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .shadow(color: DesignSystem.Colors.githubBorder.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
    .environmentObject(DependencyContainer.shared)
} 