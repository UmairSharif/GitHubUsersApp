//
//  GitHubUsersApp.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

@main
struct GitHubUsersApp: App {
    
    @StateObject private var dependencyContainer = DependencyContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencyContainer.router)
                .environmentObject(dependencyContainer)
        }
    }
} 