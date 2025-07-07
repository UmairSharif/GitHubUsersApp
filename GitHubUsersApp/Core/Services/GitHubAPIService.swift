//
//  GitHubAPIService.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import os.log

/// GitHub API service that directly implements HTTPClient
struct GitHubService: HTTPClient, GitHubServiceProtocol {
    
    private let httpClient: HTTPClient
    private let logger = Logger(subsystem: "com.githubusersapp.api", category: "GitHubService")
    
    init(httpClient: HTTPClient = HTTPClientImpl()) {
        self.httpClient = httpClient
        logger.info("GitHubService initialized")
    }
    
    // MARK: - HTTPClient Implementation
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, NetworkError> {
        return await httpClient.sendRequest(endpoint: endpoint, responseModel: responseModel)
    }
    
    // MARK: - GitHubServiceProtocol Implementation
    func searchUsers(query: String, page: Int, perPage: Int) async -> Result<SearchResponse<GitHubUser>, NetworkError> {
        logger.info("Searching users with query: '\(query)', page: \(page), perPage: \(perPage)")
        
        let endpoint = AppEndpoints.searchUsers(query: query.isEmpty ? "a" : query, page: page, perPage: perPage)
        let result = await sendRequest(endpoint: endpoint, responseModel: SearchResponse<GitHubUser>.self)
        
        switch result {
        case .success(let response):
            logger.info("Search completed successfully. Found \(response.totalCount) total users, returned \(response.items.count) users")
        case .failure(let error):
            logger.error("Failed to search users: \(error.localizedDescription)")
        }
        
        return result
    }
    
    func getUserDetails(username: String) async -> Result<GitHubUser, NetworkError> {
        logger.info("Fetching user details for username: '\(username)'")
        
        let endpoint = AppEndpoints.getUserDetails(username: username)
        let result = await sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success(let user):
            logger.info("User details fetched successfully for '\(username)': \(user.displayName)")
        case .failure(let error):
            logger.error("Failed to fetch user details: \(error.localizedDescription)")
        }
        
        return result
    }
    
    func getUserRepositories(username: String, page: Int, perPage: Int) async -> Result<[GitHubRepository], NetworkError> {
        logger.info("Fetching repositories for user: '\(username)', page: \(page), perPage: \(perPage)")
        
        let endpoint = AppEndpoints.getUserRepositories(username: username, page: page, perPage: perPage)
        let result = await sendRequest(endpoint: endpoint, responseModel: [GitHubRepository].self)
        
        switch result {
        case .success(let repositories):
            logger.info("Repositories fetched successfully for '\(username)'. Found \(repositories.count) repositories")
        case .failure(let error):
            logger.error("Failed to fetch repositories: \(error.localizedDescription)")
        }
        
        return result
    }
    
    func getUserNonForkedRepositories(username: String, page: Int, perPage: Int) async -> Result<[GitHubRepository], NetworkError> {
        logger.info("Fetching non-forked repositories for user: '\(username)', page: \(page), perPage: \(perPage)")
        
        let endpoint = AppEndpoints.getUserNonForkedRepositories(username: username, page: page, perPage: perPage)
        let result = await sendRequest(endpoint: endpoint, responseModel: [GitHubRepository].self)
        
        switch result {
        case .success(let allRepos):
            // Filter out forked repositories (double check in case API doesn't filter properly)
            let nonForkedRepos = allRepos.filter { !$0.fork }
            logger.info("Non-forked repositories fetched successfully for '\(username)'. Found \(nonForkedRepos.count) non-forked repositories out of \(allRepos.count) total")
            return .success(nonForkedRepos)
        case .failure(let error):
            logger.error("Failed to fetch non-forked repositories: \(error.localizedDescription)")
            return .failure(error)
        }
    }
} 