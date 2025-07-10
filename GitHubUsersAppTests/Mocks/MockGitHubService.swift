import Foundation
@testable import GitHubUsersApp

final class MockGitHubService: GitHubServiceProtocol {
    
    // MARK: - Mock Configuration
    private var searchUsersResponses: [String: Result<SearchResponse<GitHubUser>, NetworkError>] = [:]
    private var userDetailsResponses: [String: Result<GitHubUser, NetworkError>] = [:]
    private var userRepositoriesResponses: [String: Result<[GitHubRepository], NetworkError>] = [:]
    private var userNonForkedRepositoriesResponses: [String: Result<[GitHubRepository], NetworkError>] = [:]
    
    // MARK: - Call History
    private var callHistory: [ServiceCall] = []
    
    struct ServiceCall {
        let method: String
        let parameters: [String: Any]
        let timestamp: Date
    }
    
    // MARK: - Mock Configuration Methods
    func mockSearchUsers(query: String, page: Int, perPage: Int, response: Result<SearchResponse<GitHubUser>, NetworkError>) {
        let key = "searchUsers_\(query)_\(page)_\(perPage)"
        searchUsersResponses[key] = response
    }
    
    func mockUserDetails(username: String, response: Result<GitHubUser, NetworkError>) {
        userDetailsResponses[username] = response
    }
    
    func mockUserRepositories(username: String, page: Int, perPage: Int, response: Result<[GitHubRepository], NetworkError>) {
        let key = "userRepositories_\(username)_\(page)_\(perPage)"
        userRepositoriesResponses[key] = response
    }
    
    func mockUserNonForkedRepositories(username: String, page: Int, perPage: Int, response: Result<[GitHubRepository], NetworkError>) {
        let key = "userNonForkedRepositories_\(username)_\(page)_\(perPage)"
        userNonForkedRepositoriesResponses[key] = response
    }
    
    func clearMocks() {
        searchUsersResponses.removeAll()
        userDetailsResponses.removeAll()
        userRepositoriesResponses.removeAll()
        userNonForkedRepositoriesResponses.removeAll()
        callHistory.removeAll()
    }
    
    // MARK: - Test Helpers
    var callCount: Int {
        return callHistory.count
    }
    
    func wasMethodCalled(_ method: String) -> Bool {
        return callHistory.contains { $0.method == method }
    }
    
    func callsFor(_ method: String) -> [ServiceCall] {
        return callHistory.filter { $0.method == method }
    }
    
    func getLastCall() -> ServiceCall? {
        return callHistory.last
    }
    
    // MARK: - GitHubServiceProtocol Implementation
    func searchUsers(query: String, page: Int, perPage: Int) async -> Result<SearchResponse<GitHubUser>, NetworkError> {
        
        // Record the call
        let call = ServiceCall(
            method: "searchUsers",
            parameters: ["query": query, "page": page, "perPage": perPage],
            timestamp: Date()
        )
        callHistory.append(call)
        
        let key = "searchUsers_\(query)_\(page)_\(perPage)"
        
        // Return mock response or default error
        return searchUsersResponses[key] ?? .failure(.customError("No mock response configured for searchUsers with query: \(query), page: \(page), perPage: \(perPage)"))
    }
    
    func getUserDetails(username: String) async -> Result<GitHubUser, NetworkError> {
        
        // Record the call
        let call = ServiceCall(
            method: "getUserDetails",
            parameters: ["username": username],
            timestamp: Date()
        )
        callHistory.append(call)
        
        // Return mock response or default error
        return userDetailsResponses[username] ?? .failure(.customError("No mock response configured for getUserDetails with username: \(username)"))
    }
    
    func getUserRepositories(username: String, page: Int, perPage: Int) async -> Result<[GitHubRepository], NetworkError> {
        
        // Record the call
        let call = ServiceCall(
            method: "getUserRepositories",
            parameters: ["username": username, "page": page, "perPage": perPage],
            timestamp: Date()
        )
        callHistory.append(call)
        
        let key = "userRepositories_\(username)_\(page)_\(perPage)"
        
        // Return mock response or default error
        return userRepositoriesResponses[key] ?? .failure(.customError("No mock response configured for getUserRepositories with username: \(username), page: \(page), perPage: \(perPage)"))
    }
    
    func getUserNonForkedRepositories(username: String, page: Int, perPage: Int) async -> Result<[GitHubRepository], NetworkError> {
        
        // Record the call
        let call = ServiceCall(
            method: "getUserNonForkedRepositories",
            parameters: ["username": username, "page": page, "perPage": perPage],
            timestamp: Date()
        )
        callHistory.append(call)
        
        let key = "userNonForkedRepositories_\(username)_\(page)_\(perPage)"
        
        // Return mock response or default error
        return userNonForkedRepositoriesResponses[key] ?? .failure(.customError("No mock response configured for getUserNonForkedRepositories with username: \(username), page: \(page), perPage: \(perPage)"))
    }
}

// MARK: - Test Data Factory
extension MockGitHubService {
    
    static func createMockSearchResponse(totalCount: Int = 100, users: [GitHubUser]) -> SearchResponse<GitHubUser> {
        return SearchResponse(
            totalCount: totalCount,
            incompleteResults: false,
            items: users
        )
    }
    
    static func createMockUsers(count: Int = 5) -> [GitHubUser] {
        return (1...count).map { index in
            GitHubUser(
                id: index,
                login: "user\(index)",
                avatarUrl: "https://avatars.githubusercontent.com/u/\(index)?v=4",
                type: "User",
                siteAdmin: false,
                name: "User \(index)",
                company: "Company \(index)",
                blog: "https://blog\(index).com",
                location: "City \(index)",
                email: "user\(index)@example.com",
                bio: "Bio for user \(index)",
                publicRepos: 10 + index,
                publicGists: 5 + index,
                followers: 100 + index,
                following: 50 + index,
                createdAt: "2020-01-01T00:00:00Z",
                updatedAt: "2023-01-01T00:00:00Z"
            )
        }
    }
    
    static func createMockRepositories(count: Int = 5, forUser username: String = "testuser") -> [GitHubRepository] {
        return (1...count).map { index in
            GitHubRepository(
                id: index,
                name: "repo\(index)",
                fullName: "\(username)/repo\(index)",
                description: "Description for repo \(index)",
                language: index % 2 == 0 ? "Swift" : "JavaScript",
                stargazersCount: 10 + index,
                forksCount: 5 + index,
                openIssuesCount: index,
                size: 1024 + index,
                defaultBranch: "main",
                visibility: "public",
                fork: false,
                htmlUrl: "https://github.com/\(username)/repo\(index)",
                cloneUrl: "https://github.com/\(username)/repo\(index).git",
                createdAt: "2020-01-01T00:00:00Z",
                updatedAt: "2023-01-01T00:00:00Z",
                pushedAt: "2023-01-01T00:00:00Z",
                owner: GitHubUser(
                    id: 1,
                    login: username,
                    avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
                    type: "User",
                    siteAdmin: false
                )
            )
        }
    }
} 