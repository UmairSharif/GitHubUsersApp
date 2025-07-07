//
//  APIKeyConfigView.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import SwiftUI

struct APIKeyConfigView: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @State private var apiKey = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "key.fill")
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("GitHub API Configuration")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.githubText)
            
            Text("Add your GitHub Personal Access Token to increase the API rate limit from 60 to 5,000 requests per hour.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("GitHub Personal Access Token")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.githubText)
                
                SecureField("Enter your GitHub API key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(DesignSystem.Typography.body)
                
                Text("Your API key is stored locally and never shared.")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.githubTextSecondary)
            }
            
            HStack(spacing: DesignSystem.Spacing.md) {
                Button("Save API Key") {
                    saveAPIKey()
                }
                .primaryButtonStyle()
                .disabled(apiKey.isEmpty)
                
                Button("Clear API Key") {
                    clearAPIKey()
                }
                .secondaryButtonStyle()
            }
            
            if dependencyContainer.hasAPIKey() {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.success)
                        Text("API Key Configured")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.success)
                    }
                    
                    Text("Rate limit: 5,000 requests/hour")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                }
                .padding()
                .background(DesignSystem.Colors.success.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.md)
            } else {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(DesignSystem.Colors.warning)
                        Text("No API Key Configured")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.warning)
                    }
                    
                    Text("Rate limit: 60 requests/hour")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.githubTextSecondary)
                }
                .padding()
                .background(DesignSystem.Colors.warning.opacity(0.1))
                .cornerRadius(DesignSystem.CornerRadius.md)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.background)
        .alert("API Key Configuration", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }
        
        dependencyContainer.setGitHubAPIKey(apiKey)
        alertMessage = "API key saved successfully! Please restart the app for changes to take effect."
        showingAlert = true
        apiKey = ""
    }
    
    private func clearAPIKey() {
        GitHubAPIKeyManager.shared.removeAPIKey()
        alertMessage = "API key cleared. Please restart the app for changes to take effect."
        showingAlert = true
    }
}

#Preview {
    APIKeyConfigView()
        .environmentObject(DependencyContainer.shared)
} 
