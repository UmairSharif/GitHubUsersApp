//
//  BaseViewModel.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import SwiftUI

/// Base protocol for all view models
@MainActor
protocol BaseViewModel: ObservableObject {
    /// Loading state
    var isLoading: Bool { get set }
    
    /// Error state
    var errorMessage: String? { get set }
    
    /// Whether there's an error
    var hasError: Bool { get }
    
    /// Clear error message
    func clearError()
    
    /// Show error message
    /// - Parameter message: The error message to display
    func showError(_ message: String)
}

// MARK: - Default Implementation
extension BaseViewModel {
    var hasError: Bool {
        return errorMessage != nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
} 