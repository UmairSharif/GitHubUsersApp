//
//  RouterProtocol.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

/// Protocol defining navigation capabilities
protocol RouterProtocol: ObservableObject {
    /// The current navigation path
    var path: NavigationPath { get set }
    
    /// Navigate to a specific route
    /// - Parameter route: The route to navigate to
    func navigate(to route: Route)
    
    /// Navigate back
    func navigateBack()
    
    /// Navigate to root
    func navigateToRoot()
}

/// Available navigation routes
enum Route: Hashable {
    case userList
    case userDetail
} 
