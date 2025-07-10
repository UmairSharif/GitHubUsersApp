//
//  ContentView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    
    var body: some View {
        NavigationStack(path: $router.path) {
            UserListView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .userList:
                        UserListView()
                    case .userDetail(let user):
                        UserRepositoryView(user: user)
                    case .repositoryWebView(let url):
                        RepositoryWebView(url: url)
                    case .apiKeyConfig:
                        APIKeyConfigView()
                    case .favorites:
                        FavoritesView()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Router())
        .environmentObject(DependencyContainer.shared)
} 