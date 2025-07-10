import Testing
import Foundation
import SwiftUI
@testable import GitHubUsersApp

@MainActor
struct IntegrationTests {
    
    // MARK: - Test Setup
    
    private func setupTest() {
        // Clear any shared state that might affect tests
        UserDefaults.standard.removeObject(forKey: "GitHubAPIKey")
    }
    
    private func createTestDependencies() -> (
        httpClient: MockHTTPClient,
        gitHubService: GitHubService,
        router: MockRouter
    ) {
        setupTest() // Clear state before each test
        let httpClient = MockHTTPClient()
        httpClient.clearMocks() // Clear mock state
        let gitHubService = GitHubService(httpClient: httpClient)
        let router = MockRouter()
        router.clearNavigationHistory() // Clear navigation history
        return (httpClient, gitHubService, router)
    }
    
    // MARK: - Complete User List Flow Tests
    
    @Test func testCompleteUserListFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Create view model first
        let viewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure mock responses AFTER creating view model (so they don't get cleared)
        let initialResponse = SearchResponse(
            totalCount: 2,
            incompleteResults: false,
            items: [
                MockHTTPClient.mockUser1,
                MockHTTPClient.mockUser2
            ]
        )
        
        let searchResponse = SearchResponse(
            totalCount: 2,
            incompleteResults: false,
            items: [
                MockHTTPClient.mockUser1,
                MockHTTPClient.mockUser2
            ]
        )
        
        // Configure initial load response
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "a", page: 1, perPage: 20),
            response: initialResponse
        )
        
        // Configure search response
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: searchResponse
        )
        
        // Test initial state
        #expect(viewModel.users.isEmpty)
        #expect(!viewModel.isLoadingUsers)
        #expect(!viewModel.hasError)
        
        // Load initial users first to establish previous state
        await viewModel.loadUsers()
        
        // Verify initial users loaded
        #expect(viewModel.users.count == 2)
        #expect(!viewModel.isLoadingUsers)
        #expect(!viewModel.hasError)
        
        // Test search functionality
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        
        // Verify search results
        #expect(viewModel.users.count == 2)
        #expect(viewModel.users[0].login == "testuser1")
        #expect(viewModel.users[1].login == "testuser2")
        #expect(!viewModel.isLoadingUsers)
        #expect(!viewModel.hasError)
        
        // Test user selection and navigation
        let selectedUser = viewModel.users[0]
        viewModel.selectUser(selectedUser)
        
        // Verify navigation occurred
        #expect(router.path.count == 1)
        
        // Test search clearing
        viewModel.searchText = ""
        
        // Verify state restoration
        #expect(viewModel.users.count == 2) // Should maintain previous results
        #expect(!viewModel.isLoadingUsers)
    }
    
    @Test func testUserListErrorHandlingFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Create view model first
        let viewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure error response AFTER creating view model (so it doesn't get cleared)
        httpClient.mockError(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            error: NetworkError.serverError(422)
        )
        
        // Test error handling
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.hasError)
        #expect(viewModel.errorMessage != nil)
        
        // Test error recovery
        let successResponse = SearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [MockHTTPClient.mockUser1]
        )
        
        httpClient.clearMocks()
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: successResponse
        )
        
        await viewModel.searchUsers()
        
        #expect(viewModel.users.count == 1)
        #expect(!viewModel.hasError)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Complete User Repository Flow Tests
    
    @Test func testCompleteUserRepositoryFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Create view model first
        let viewModel = UserRepositoryViewModel(
            user: MockHTTPClient.mockUser1,
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure user details response AFTER creating view model (so it doesn't get cleared)
        httpClient.mockResponse(
            for: AppEndpoints.getUserDetails(username: "testuser1"),
            response: MockHTTPClient.mockUser1
        )
        
        // Configure repositories response
        let repositories = [
            MockHTTPClient.mockRepository1,
            MockHTTPClient.mockRepository2
        ]
        
        httpClient.mockResponse(
            for: AppEndpoints.getUserNonForkedRepositories(username: "testuser1", page: 1, perPage: 20),
            response: repositories
        )
        
        // Test initial state
        #expect(viewModel.user.login == "testuser1")
        #expect(viewModel.repositories.isEmpty)
        #expect(!viewModel.isLoadingUserDetails)
        #expect(!viewModel.isLoadingRepositories)
        
        // Load user details and repositories
        await viewModel.loadUserDetails()
        await viewModel.loadRepositories()
        
        // Verify data loaded
        #expect(viewModel.user.login == "testuser1")
        #expect(viewModel.repositories.count == 2)
        #expect(viewModel.repositories[0].name == "test-repo-1")
        #expect(viewModel.repositories[1].name == "test-repo-2")
        #expect(!viewModel.isLoadingUserDetails)
        #expect(!viewModel.isLoadingRepositories)
        #expect(!viewModel.hasError)
        
        // Test repository navigation
        let repository = viewModel.repositories[0]
        viewModel.openRepository(repository)
        
        // Verify navigation to WebView
        #expect(router.path.count == 1)
    }
    
    @Test func testUserRepositoryErrorHandlingFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Create view model first
        let viewModel = UserRepositoryViewModel(
            user: MockHTTPClient.mockUser1,
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure user details success AFTER creating view model (so it doesn't get cleared)
        httpClient.mockResponse(
            for: AppEndpoints.getUserDetails(username: "testuser1"),
            response: MockHTTPClient.mockUser1
        )
        
        // Configure repository error
        httpClient.mockError(
            for: AppEndpoints.getUserNonForkedRepositories(username: "testuser1", page: 1, perPage: 20),
            error: NetworkError.rateLimitExceeded
        )
        
        await viewModel.loadUserDetails()
        await viewModel.loadRepositories()
        
        // Verify user details loaded but repositories failed
        #expect(viewModel.user.login == "testuser1")
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.hasError)
        #expect(viewModel.errorMessage != nil)
        
        // Test error recovery
        httpClient.clearMocks()
        httpClient.mockResponse(
            for: AppEndpoints.getUserDetails(username: "testuser1"),
            response: MockHTTPClient.mockUser1
        )
        httpClient.mockResponse(
            for: AppEndpoints.getUserNonForkedRepositories(username: "testuser1", page: 1, perPage: 20),
            response: [MockHTTPClient.mockRepository1]
        )
        
        await viewModel.loadRepositories()
        
        #expect(viewModel.repositories.count == 1)
        #expect(!viewModel.hasError)
    }
    
    // MARK: - Navigation Integration Tests
    
    @Test func testCompleteNavigationFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Start with user list
        let userListViewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure responses AFTER creating view model (so they don't get cleared)
        let searchResponse = SearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [MockHTTPClient.mockUser1]
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: searchResponse
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.getUserDetails(username: "testuser1"),
            response: MockHTTPClient.mockUser1
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.getUserNonForkedRepositories(username: "testuser1", page: 1, perPage: 20),
            response: [MockHTTPClient.mockRepository1]
        )
        
        // Search and select user
        userListViewModel.searchText = "test"
        await userListViewModel.searchUsers()
        
        #expect(userListViewModel.users.count == 1)
        
        userListViewModel.selectUser(userListViewModel.users[0])
        #expect(router.path.count == 1)
        
        // Navigate to user repository view
        let userRepositoryViewModel = UserRepositoryViewModel(
            user: userListViewModel.users[0],
            gitHubService: gitHubService,
            router: router
        )
        
        await userRepositoryViewModel.loadUserDetails()
        await userRepositoryViewModel.loadRepositories()
        
        #expect(userRepositoryViewModel.repositories.count == 1)
        
        // Navigate to repository WebView
        userRepositoryViewModel.openRepository(userRepositoryViewModel.repositories[0])
        #expect(router.path.count == 2)
        
        // Test back navigation
        router.navigateBack()
        #expect(router.path.count == 1)
        
        router.navigateBack()
        #expect(router.path.count == 0)
    }
    
    @Test func testAPIKeyConfigurationFlow() async throws {
        let router = MockRouter()
        
        // Test navigation to API config
        router.navigate(to: .apiKeyConfig)
        #expect(router.path.count == 1)
        
        // Test API key management
        let apiKeyManager = GitHubAPIKeyManager.shared
        
        // Clear any existing key
        apiKeyManager.removeAPIKey()
        #expect(apiKeyManager.apiKey == nil)
        
        // Set new API key
        let testAPIKey = "ghp_test_api_key_123456789"
        apiKeyManager.setAPIKey(testAPIKey)
        #expect(apiKeyManager.apiKey == testAPIKey)
        
        // Clear API key
        apiKeyManager.removeAPIKey()
        #expect(apiKeyManager.apiKey == nil)
    }
    
    // MARK: - Error Recovery Integration Tests
    
    @Test func testNetworkErrorRecoveryFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        let viewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        // Test network error AFTER creating view model (so it doesn't get cleared)
        httpClient.mockError(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            error: NetworkError.networkError(URLError(.notConnectedToInternet))
        )
        
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        
        #expect(viewModel.hasError)
        #expect(viewModel.users.isEmpty)
        
        // Test recovery after network restored
        let successResponse = SearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [MockHTTPClient.mockUser1]
        )
        
        httpClient.clearMocks()
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: successResponse
        )
        
        await viewModel.searchUsers()
        
        #expect(!viewModel.hasError)
        #expect(viewModel.users.count == 1)
    }
    
    @Test func testRateLimitHandlingFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        let viewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        // Test rate limit error AFTER creating view model (so it doesn't get cleared)
        httpClient.mockError(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            error: NetworkError.rateLimitExceeded
        )
        
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        
        #expect(viewModel.hasError)
        #expect(viewModel.errorMessage?.contains("rate limit") == true)
        
        // Test recovery after rate limit reset
        let successResponse = SearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [MockHTTPClient.mockUser1]
        )
        
        httpClient.clearMocks()
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: successResponse
        )
        
        await viewModel.searchUsers()
        
        #expect(!viewModel.hasError)
        #expect(viewModel.users.count == 1)
    }
    
    // MARK: - Concurrent Operations Integration Tests
    
    @Test func testConcurrentOperationsFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        let userListViewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        let userRepositoryViewModel = UserRepositoryViewModel(
            user: MockHTTPClient.mockUser1,
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure responses AFTER creating view models (so they don't get cleared)
        let searchResponse = SearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [MockHTTPClient.mockUser1]
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: searchResponse
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.getUserDetails(username: "testuser1"),
            response: MockHTTPClient.mockUser1
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.getUserNonForkedRepositories(username: "testuser1", page: 1, perPage: 20),
            response: [MockHTTPClient.mockRepository1]
        )
        
        // Test concurrent operations
        async let searchTask = userListViewModel.searchUsers()
        async let userDetailsTask = userRepositoryViewModel.loadUserDetails()
        async let repositoriesTask = userRepositoryViewModel.loadRepositories()
        
        userListViewModel.searchText = "test"
        
        // Wait for all operations to complete
        await searchTask
        await userDetailsTask
        await repositoriesTask
        
        // Verify all operations completed successfully
        #expect(userListViewModel.users.count == 1)
        #expect(!userListViewModel.hasError)
        
        #expect(userRepositoryViewModel.user.login == "testuser1")
        #expect(userRepositoryViewModel.repositories.count == 1)
    }
    
    // MARK: - Data Consistency Integration Tests
    
    @Test func testDataConsistencyFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Create view model first
        let viewModel = UserRepositoryViewModel(
            user: MockHTTPClient.mockUser1,
            gitHubService: gitHubService,
            router: router
        )
        
        // Configure user details with updated information AFTER creating view model (so it doesn't get cleared)
        let updatedUser = GitHubUser(
            id: MockHTTPClient.mockUser1.id,
            login: MockHTTPClient.mockUser1.login,
            avatarUrl: MockHTTPClient.mockUser1.avatarUrl,
            type: MockHTTPClient.mockUser1.type,
            siteAdmin: MockHTTPClient.mockUser1.siteAdmin,
            name: "Updated Test User",
            company: "Updated Company",
            blog: MockHTTPClient.mockUser1.blog,
            location: "Updated Location",
            email: MockHTTPClient.mockUser1.email,
            bio: "Updated bio",
            publicRepos: 50, // Updated count
            publicGists: MockHTTPClient.mockUser1.publicGists,
            followers: 200, // Updated count
            following: MockHTTPClient.mockUser1.following,
            createdAt: MockHTTPClient.mockUser1.createdAt,
            updatedAt: "2024-01-01T00:00:00Z" // Updated timestamp
        )
        
        httpClient.mockResponse(
            for: AppEndpoints.getUserDetails(username: "testuser1"),
            response: updatedUser
        )
        
        // Verify initial state
        #expect(viewModel.user.name == "Test User 1")
        #expect(viewModel.user.publicRepos == 25)
        #expect(viewModel.user.followers == 100)
        
        // Load updated user details
        await viewModel.loadUserDetails()
        
        // Verify data consistency after update
        #expect(viewModel.user.name == "Updated Test User")
        #expect(viewModel.user.company == "Updated Company")
        #expect(viewModel.user.publicRepos == 50)
        #expect(viewModel.user.followers == 200)
        #expect(viewModel.user.bio == "Updated bio")
    }
    
    // MARK: - Performance Integration Tests
    
    @Test func testLargeDataSetHandlingFlow() async throws {
        let (httpClient, gitHubService, router) = createTestDependencies()
        
        // Create view model first
        let viewModel = UserListViewModel(
            gitHubService: gitHubService,
            router: router
        )
        
        // Create large dataset
        let largeUserList = (1...100).map { index in
            GitHubUser(
                id: index,
                login: "user\(index)",
                avatarUrl: "https://avatars.githubusercontent.com/u/\(index)?v=4",
                type: "User",
                siteAdmin: false,
                name: "User \(index)",
                company: "Company \(index)",
                blog: nil,
                location: "Location \(index)",
                email: nil,
                bio: "Bio for user \(index)",
                publicRepos: index * 2,
                publicGists: index,
                followers: index * 10,
                following: index * 5,
                createdAt: "2020-01-01T00:00:00Z",
                updatedAt: "2023-01-01T00:00:00Z"
            )
        }
        
        let searchResponse = SearchResponse(
            totalCount: 100,
            incompleteResults: false,
            items: largeUserList
        )
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        httpClient.mockResponse(
            for: AppEndpoints.searchUsers(query: "test", page: 1, perPage: 20),
            response: searchResponse
        )
        
        // Test handling large dataset
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        
        #expect(viewModel.users.count == 100)
        #expect(!viewModel.hasError)
        
        // Test navigation with large dataset
        let selectedUser = viewModel.users[50]
        viewModel.selectUser(selectedUser)
        
        #expect(router.path.count == 1)
        #expect(selectedUser.login == "user51")
    }
} 