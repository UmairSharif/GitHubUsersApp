//
//  NetworkServiceProtocol.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

/// Protocol defining GitHub API service capabilities
protocol GitHubServiceProtocol {
    /// Fetches a list of GitHub users
    /// - Parameters:
    ///   - query: Search query for users
    ///   - page: Page number for pagination
    ///   - perPage: Number of items per page
    /// - Returns: Search response containing users
    func searchUsers(query: String, page: Int, perPage: Int) async -> Result<SearchResponse<GitHubUser>, NetworkError>
    
    /// Fetches detailed information about a specific user
    /// - Parameter username: The GitHub username
    /// - Returns: Detailed user information
    func getUserDetails(username: String) async -> Result<GitHubUser, NetworkError>
    
    /// Fetches repositories for a specific user
    /// - Parameters:
    ///   - username: The GitHub username
    ///   - page: Page number for pagination
    ///   - perPage: Number of items per page
    /// - Returns: Array of user repositories
    func getUserRepositories(username: String, page: Int, perPage: Int) async -> Result<[GitHubRepository], NetworkError>
    
    /// Fetches non-forked repositories for a specific user
    /// - Parameters:
    ///   - username: The GitHub username
    ///   - page: Page number for pagination
    ///   - perPage: Number of items per page
    /// - Returns: Array of non-forked repositories
    func getUserNonForkedRepositories(username: String, page: Int, perPage: Int) async -> Result<[GitHubRepository], NetworkError>
} 