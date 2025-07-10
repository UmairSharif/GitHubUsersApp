import Testing
import Foundation
@testable import GitHubUsersApp

@MainActor
struct UserListViewModelTests {
    
    // MARK: - Test Setup
    
    private func setupTest() {
        // Clear any shared state that might affect tests
        UserDefaults.standard.removeObject(forKey: "GitHubAPIKey")
    }
    
    private func createViewModel(
        mockService: MockGitHubService = MockGitHubService(),
        mockRouter: MockRouter = MockRouter()
    ) -> UserListViewModel {
        setupTest() // Clear state before each test
        mockService.clearMocks() // Clear mock state
        mockRouter.clearNavigationHistory() // Clear navigation history
        return UserListViewModel(gitHubService: mockService, router: mockRouter)
    }
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.hasError == false)
        #expect(mockService.callCount == 0)
        #expect(mockRouter.navigationCount == 0)
    }
    
    // MARK: - Load Users Tests
    
    @Test func testLoadUsersSuccess() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let mockUsers = MockGitHubService.createMockUsers(count: 3)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 3, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(mockResponse))
        
        await viewModel.loadUsers()
        
        #expect(viewModel.users.count == 3)
        #expect(viewModel.users[0].login == "user1")
        #expect(viewModel.users[1].login == "user2")
        #expect(viewModel.users[2].login == "user3")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("searchUsers"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadUsersNetworkError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .failure(.networkError(NSError(domain: "Test", code: -1, userInfo: nil))))
        
        await viewModel.loadUsers()
        
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("searchUsers"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadUsersRateLimitExceeded() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .failure(.rateLimitExceeded))
        
        await viewModel.loadUsers()
        
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("searchUsers"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadUsersRefresh() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let mockUsers = MockGitHubService.createMockUsers(count: 2)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 2, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(mockResponse))
        
        await viewModel.loadUsers(isRefresh: true)
        
        #expect(viewModel.users.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("searchUsers"))
        #expect(mockService.callCount == 1)
    }
    
    // MARK: - Search Tests
    
    @Test func testSearchTextChange() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let mockUsers = MockGitHubService.createMockUsers(count: 1)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "swift", page: 1, perPage: 20, response: .success(mockResponse))
        
        viewModel.searchText = "swift"
        
        // Wait for throttled search
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        #expect(viewModel.searchText == "swift")
        #expect(viewModel.users.count == 1)
        #expect(mockService.wasMethodCalled("searchUsers"))
    }
    
    @Test func testSearchTextClear() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Setup initial users
        let initialUsers = MockGitHubService.createMockUsers(count: 3)
        let initialResponse = MockGitHubService.createMockSearchResponse(totalCount: 3, users: initialUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure initial mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(initialResponse))
        
        // Load initial users
        await viewModel.loadUsers()
        #expect(viewModel.users.count == 3)
        
        // Setup search results
        let searchUsers = MockGitHubService.createMockUsers(count: 1)
        let searchResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: searchUsers)
        mockService.mockSearchUsers(query: "test", page: 1, perPage: 20, response: .success(searchResponse))
        
        // Perform search
        viewModel.searchText = "test"
        try await Task.sleep(nanoseconds: 600_000_000)
        
        #expect(viewModel.users.count == 1)
        
        // Clear search
        viewModel.searchText = ""
        
        // Wait a bit for state restoration to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Should restore previous state
        #expect(viewModel.users.count == 3)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testSearchThrottling() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let mockUsers = MockGitHubService.createMockUsers(count: 1)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "swift", page: 1, perPage: 20, response: .success(mockResponse))
        
        // Rapidly change search text
        viewModel.searchText = "s"
        viewModel.searchText = "sw"
        viewModel.searchText = "swi"
        viewModel.searchText = "swif"
        viewModel.searchText = "swift"
        
        // Wait for throttled search
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Should only make one call for the final search term
        #expect(mockService.callCount == 1)
        let lastCall = mockService.getLastCall()
        #expect(lastCall?.parameters["query"] as? String == "swift")
    }
    
    // MARK: - Pagination Tests
    
    @Test func testLoadMoreUsers() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Setup first page with more users to trigger threshold
        let firstPageUsers = MockGitHubService.createMockUsers(count: 15)
        let firstPageResponse = MockGitHubService.createMockSearchResponse(totalCount: 20, users: firstPageUsers)
        
        // Setup second page
        let secondPageUsers = [
            GitHubUser(id: 16, login: "user16", avatarUrl: "https://avatars.githubusercontent.com/u/16?v=4", type: "User", siteAdmin: false),
            GitHubUser(id: 17, login: "user17", avatarUrl: "https://avatars.githubusercontent.com/u/17?v=4", type: "User", siteAdmin: false),
            GitHubUser(id: 18, login: "user18", avatarUrl: "https://avatars.githubusercontent.com/u/18?v=4", type: "User", siteAdmin: false),
            GitHubUser(id: 19, login: "user19", avatarUrl: "https://avatars.githubusercontent.com/u/19?v=4", type: "User", siteAdmin: false),
            GitHubUser(id: 20, login: "user20", avatarUrl: "https://avatars.githubusercontent.com/u/20?v=4", type: "User", siteAdmin: false)
        ]
        let secondPageResponse = MockGitHubService.createMockSearchResponse(totalCount: 20, users: secondPageUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mocks AFTER creating view model (so they don't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(firstPageResponse))
        mockService.mockSearchUsers(query: "a", page: 2, perPage: 20, response: .success(secondPageResponse))
        
        // Load first page
        await viewModel.loadUsers()
        #expect(viewModel.users.count == 15)
        
        // Simulate loading more users by calling loadMoreUsersIfNeeded with the 11th user (threshold position)
        await viewModel.loadMoreUsersIfNeeded(currentUser: firstPageUsers[10])
        
        // Debug: Check if the second page was actually loaded
        #expect(mockService.callCount == 2)
        #expect(viewModel.users.count == 20)
        
        // Verify the new users were added correctly
        #expect(viewModel.users[15].login == "user16")
        #expect(viewModel.users[16].login == "user17")
        #expect(viewModel.users[17].login == "user18")
        #expect(viewModel.users[18].login == "user19")
        #expect(viewModel.users[19].login == "user20")
    }
    
    @Test func testLoadMoreUsersNoMorePages() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Setup response with less than full page (indicates no more pages)
        let users = MockGitHubService.createMockUsers(count: 10)
        let response = MockGitHubService.createMockSearchResponse(totalCount: 10, users: users)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(response))
        
        // Load users
        await viewModel.loadUsers()
        #expect(viewModel.users.count == 10)
        
        // Try to load more (should not make another call since we don't have enough users to trigger threshold)
        await viewModel.loadMoreUsersIfNeeded(currentUser: users[0])
        #expect(viewModel.users.count == 10)
        #expect(mockService.callCount == 1) // Should still be 1
    }
    
    @Test func testLoadMoreUsersWithSmallArray() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Setup response with only 3 users (less than threshold)
        let smallUsers = MockGitHubService.createMockUsers(count: 3)
        let searchResponse = MockGitHubService.createMockSearchResponse(totalCount: 3, users: smallUsers)
        mockService.mockSearchUsers(query: "test", page: 1, perPage: 20, response: .success(searchResponse))
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Load users
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        #expect(viewModel.users.count == 3)
        
        // This should not crash even with small array
        await viewModel.loadMoreUsersIfNeeded(currentUser: smallUsers[0])
        #expect(viewModel.users.count == 3) // Should remain unchanged
        #expect(mockService.callCount == 1) // Should not make additional calls
    }
    
    @Test func testLoadMoreUsersWithNonExistentUser() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Setup response with users
        let users = MockGitHubService.createMockUsers(count: 10)
        let searchResponse = MockGitHubService.createMockSearchResponse(totalCount: 10, users: users)
        mockService.mockSearchUsers(query: "test", page: 1, perPage: 20, response: .success(searchResponse))
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Load users
        viewModel.searchText = "test"
        await viewModel.searchUsers()
        #expect(viewModel.users.count == 10)
        
        // Create a user that doesn't exist in the loaded users
        let nonExistentUser = GitHubUser(
            id: 999,
            login: "non-existent",
            avatarUrl: "https://avatars.githubusercontent.com/u/999?v=4",
            type: "User",
            siteAdmin: false,
            name: "Non-existent User",
            company: nil,
            blog: nil,
            location: nil,
            email: nil,
            bio: nil,
            publicRepos: 0,
            publicGists: 0,
            followers: 0,
            following: 0,
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z"
        )
        
        // This should not crash even with non-existent user
        await viewModel.loadMoreUsersIfNeeded(currentUser: nonExistentUser)
        #expect(viewModel.users.count == 10) // Should remain unchanged
        #expect(mockService.callCount == 1) // Should not make additional calls
    }
    
    // MARK: - Error Handling Tests
    
    @Test func testClearError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .failure(.networkError(NSError(domain: "Test", code: -1, userInfo: nil))))
        
        // Trigger error
        await viewModel.loadUsers()
        #expect(viewModel.hasError == true)
        #expect(viewModel.errorMessage != nil)
        
        // Clear error
        viewModel.clearError()
        #expect(viewModel.hasError == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testShowError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        let testErrorMessage = "Test error message"
        viewModel.showError(testErrorMessage)
        
        #expect(viewModel.hasError == true)
        #expect(viewModel.errorMessage == testErrorMessage)
    }
    
    // MARK: - Navigation Tests
    
    @Test func testSelectUser() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        let testUser = GitHubUser(id: 1, login: "testuser", avatarUrl: "https://example.com", type: "User", siteAdmin: false)
        
        viewModel.selectUser(testUser)
        
        #expect(mockRouter.navigationCount == 1)
        #expect(mockRouter.wasRouteCalled(.userDetail(testUser)))
        
        let lastNavigation = mockRouter.getLastNavigation()
        #expect(lastNavigation?.route == .userDetail(testUser))
    }
    
    // MARK: - Refresh Tests
    
    @Test func testRefreshUsers() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let mockUsers = MockGitHubService.createMockUsers(count: 2)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 2, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(mockResponse))
        
        await viewModel.refreshUsers()
        
        #expect(viewModel.users.count == 2)
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("searchUsers"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testRefreshUsersWithError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .failure(.serverError(500)))
        
        await viewModel.refreshUsers()
        
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("searchUsers"))
        #expect(mockService.callCount == 1)
    }
    
    // MARK: - Concurrent Operations Tests
    
    @Test func testConcurrentLoadOperations() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let mockUsers = MockGitHubService.createMockUsers(count: 1)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(mockResponse))
        
        // Start multiple concurrent load operations
        async let load1 = viewModel.loadUsers()
        async let load2 = viewModel.loadUsers()
        async let load3 = viewModel.loadUsers()
        
        await load1
        await load2
        await load3
        
        // Should only make one actual network call due to loading state protection
        #expect(mockService.callCount == 1)
        #expect(viewModel.users.count == 1)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testSearchDuringLoad() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Setup responses
        let loadUsers = MockGitHubService.createMockUsers(count: 3)
        let loadResponse = MockGitHubService.createMockSearchResponse(totalCount: 3, users: loadUsers)
        
        let searchUsers = MockGitHubService.createMockUsers(count: 1)
        let searchResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: searchUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mocks AFTER creating view model (so they don't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(loadResponse))
        mockService.mockSearchUsers(query: "test", page: 1, perPage: 20, response: .success(searchResponse))
        
        // Start load operation
        let loadTask = Task {
            await viewModel.loadUsers()
        }
        
        // Start search operation
        viewModel.searchText = "test"
        
        // Don't wait for loadTask since it gets cancelled by search
        // Just wait for the search to complete
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Search should have cancelled the load operation and completed successfully
        #expect(viewModel.searchText == "test")
        #expect(mockService.callCount >= 1)
        #expect(viewModel.users.count == 1)
        #expect(viewModel.users.first?.login == "user1")
    }
    
    // MARK: - State Management Tests
    
    @Test func testLoadingStateManagement() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let mockUsers = MockGitHubService.createMockUsers(count: 1)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(mockResponse))
        
        #expect(viewModel.isLoading == false)
        
        let loadTask = Task {
            await viewModel.loadUsers()
        }
        
        // Loading state should be managed properly
        await loadTask.value
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.users.count == 1)
    }
    
    @Test func testRefreshingStateManagement() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let mockUsers = MockGitHubService.createMockUsers(count: 1)
        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: mockUsers)
        
        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
        
        // Configure mock AFTER creating view model (so it doesn't get cleared)
        mockService.mockSearchUsers(query: "a", page: 1, perPage: 20, response: .success(mockResponse))
        
        #expect(viewModel.isRefreshing == false)
        
        let refreshTask = Task {
            await viewModel.refreshUsers()
        }
        
        await refreshTask.value
        
        #expect(viewModel.isRefreshing == false)
        #expect(viewModel.users.count == 1)
    }
    
    // MARK: - Edge Cases Tests
    
//    @Test func testEmptySearchResults() async throws {
//        let mockService = MockGitHubService()
//        let mockRouter = MockRouter()
//        
//        let emptyResponse = MockGitHubService.createMockSearchResponse(totalCount: 0, users: [])
//        
//        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
//        
//        // Configure mock AFTER creating view model (so it doesn't get cleared)
//        mockService.mockSearchUsers(query: "nonexistent", page: 1, perPage: 20, response: .success(emptyResponse))
//        
//        viewModel.searchText = "nonexistent"
//        try await Task.sleep(nanoseconds: 600_000_000)
//        
//        #expect(viewModel.users.isEmpty)
//        #expect(viewModel.errorMessage == nil)
//        #expect(mockService.wasMethodCalled("searchUsers"))
//    }
//    
//    @Test func testSearchWithSpecialCharacters() async throws {
//        let mockService = MockGitHubService()
//        let mockRouter = MockRouter()
//        
//        let mockUsers = MockGitHubService.createMockUsers(count: 1)
//        let mockResponse = MockGitHubService.createMockSearchResponse(totalCount: 1, users: mockUsers)
//        
//        let viewModel = createViewModel(mockService: mockService, mockRouter: mockRouter)
//        
//        // Configure mock AFTER creating view model (so it doesn't get cleared)
//        mockService.mockSearchUsers(query: "test@#$%", page: 1, perPage: 20, response: .success(mockResponse))
//        
//        viewModel.searchText = "test@#$%"
//        try await Task.sleep(nanoseconds: 600_000_000)
//        
//        #expect(viewModel.users.count == 1)
//        #expect(mockService.wasMethodCalled("searchUsers"))
//        
//        let lastCall = mockService.getLastCall()
//        #expect(lastCall?.parameters["query"] as? String == "test@#$%")
//    }
} 
