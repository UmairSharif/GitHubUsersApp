import Testing
import Foundation
@testable import GitHubUsersApp

@MainActor
struct UserRepositoryViewModelTests {
    
    // MARK: - Test Setup
    
    private func setupTest() {
        // Clear any shared state that might affect tests
        UserDefaults.standard.removeObject(forKey: "GitHubAPIKey")
    }
    
    private func createViewModel(
        user: GitHubUser,
        mockService: MockGitHubService = MockGitHubService(),
        mockRouter: MockRouter = MockRouter()
    ) -> UserRepositoryViewModel {
        setupTest() // Clear state before each test
        mockService.clearMocks() // Clear mock state
        mockRouter.clearNavigationHistory() // Clear navigation history
        return UserRepositoryViewModel(user: user, gitHubService: mockService, router: mockRouter)
    }
    
    private let testUser = GitHubUser(
        id: 1,
        login: "testuser",
        avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
        type: "User",
        siteAdmin: false,
        name: "Test User",
        company: "Test Company",
        blog: "https://blog.test.com",
        location: "Test City",
        email: "test@example.com",
        bio: "Test bio",
        publicRepos: 25,
        publicGists: 10,
        followers: 100,
        following: 50,
        createdAt: "2020-01-01T00:00:00Z",
        updatedAt: "2023-01-01T00:00:00Z"
    )
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        #expect(viewModel.user.login == "testuser")
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.hasError == false)
        #expect(mockService.callCount == 0)
        #expect(mockRouter.navigationCount == 0)
    }
    
    // MARK: - Load User Details Tests
    
    @Test func testLoadUserDetailsSuccess() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let detailedUser = GitHubUser(
            id: 1,
            login: "testuser",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false,
            name: "Detailed Test User",
            company: "Updated Company",
            blog: "https://updated.blog.com",
            location: "Updated City",
            email: "updated@example.com",
            bio: "Updated bio",
            publicRepos: 30,
            publicGists: 15,
            followers: 150,
            following: 75,
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2023-06-01T00:00:00Z"
        )
        
        mockService.mockUserDetails(username: "testuser", response: .success(detailedUser))
        
        await viewModel.loadUserDetails()
        
        #expect(viewModel.user.name == "Detailed Test User")
        #expect(viewModel.user.company == "Updated Company")
        #expect(viewModel.user.publicRepos == 30)
        #expect(viewModel.user.followers == 150)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("getUserDetails"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadUserDetailsNetworkError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        mockService.mockUserDetails(username: "testuser", response: .failure(.networkError(NSError(domain: "Test", code: -1, userInfo: nil))))
        
        await viewModel.loadUserDetails()
        
        #expect(viewModel.user.login == "testuser") // Should remain unchanged
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("getUserDetails"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadUserDetailsNotFound() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        mockService.mockUserDetails(username: "testuser", response: .failure(.customError("Not Found")))
        
        await viewModel.loadUserDetails()
        
        #expect(viewModel.user.login == "testuser")
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("getUserDetails"))
        #expect(mockService.callCount == 1)
    }
    
    // MARK: - Load Repositories Tests
    
    @Test func testLoadRepositoriesSuccess() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let mockRepositories = MockGitHubService.createMockRepositories(count: 3, forUser: "testuser")
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(mockRepositories))
        
        await viewModel.loadRepositories()
        
        #expect(viewModel.repositories.count == 3)
        #expect(viewModel.repositories[0].name == "repo1")
        #expect(viewModel.repositories[1].name == "repo2")
        #expect(viewModel.repositories[2].name == "repo3")
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadRepositoriesEmpty() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let emptyRepositories: [GitHubRepository] = []
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(emptyRepositories))
        
        await viewModel.loadRepositories()
        
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadRepositoriesNetworkError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .failure(.networkError(NSError(domain: "Test", code: -1, userInfo: nil))))
        
        await viewModel.loadRepositories()
        
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
        #expect(mockService.callCount == 1)
    }
    
    @Test func testLoadRepositoriesRateLimitExceeded() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .failure(.rateLimitExceeded))
        
        await viewModel.loadRepositories()
        
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
        #expect(mockService.callCount == 1)
    }
    
    // MARK: - Pagination Tests
    
    @Test func testLoadMoreRepositories() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        // Setup first page with full page (20 items) to indicate more pages exist
        let firstPageRepos = MockGitHubService.createMockRepositories(count: 20, forUser: "testuser")
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(firstPageRepos))
        
        // Setup second page
        let secondPageRepos = [
            GitHubRepository(
                id: 21, name: "repo21", fullName: "testuser/repo21", description: "Repo 21",
                language: "Swift", stargazersCount: 15, forksCount: 3, openIssuesCount: 1,
                size: 2048, defaultBranch: "main", visibility: "public", fork: false,
                htmlUrl: "https://github.com/testuser/repo21", cloneUrl: "https://github.com/testuser/repo21.git",
                createdAt: "2020-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z", pushedAt: "2023-01-01T00:00:00Z",
                owner: testUser
            )
        ]
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 2, perPage: 20, response: .success(secondPageRepos))
        
        // Load first page
        await viewModel.loadRepositories()
        #expect(viewModel.repositories.count == 20)
        
        // Simulate loading more repositories by calling loadMoreRepositoriesIfNeeded with a repo near the end
        // The threshold is at index 15 (20 - 5), so we use index 15 to trigger loading more
        await viewModel.loadMoreRepositoriesIfNeeded(currentRepository: firstPageRepos[15])
        #expect(viewModel.repositories.count == 21)
        #expect(viewModel.repositories[20].name == "repo21")
        #expect(mockService.callCount == 2)
    }
    
    @Test func testLoadMoreRepositoriesNoMorePages() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        // Setup response with less than full page (indicates no more pages)
        let repositories = MockGitHubService.createMockRepositories(count: 10, forUser: "testuser")
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(repositories))
        
        // Load repositories
        await viewModel.loadRepositories()
        #expect(viewModel.repositories.count == 10)
        
        // Try to load more (should not make another call since we don't have enough repos to trigger threshold)
        await viewModel.loadMoreRepositoriesIfNeeded(currentRepository: repositories[0])
        #expect(viewModel.repositories.count == 10)
        #expect(mockService.callCount == 1) // Should still be 1
    }
    
    @Test func testLoadMoreRepositoriesWithSmallArray() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        // Setup response with only 3 repositories (less than threshold)
        let smallRepos = MockGitHubService.createMockRepositories(count: 3, forUser: "testuser")
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(smallRepos))
        
        // Load repositories
        await viewModel.loadRepositories()
        #expect(viewModel.repositories.count == 3)
        
        // This should not crash even with small array
        await viewModel.loadMoreRepositoriesIfNeeded(currentRepository: smallRepos[0])
        #expect(viewModel.repositories.count == 3) // Should remain unchanged
        #expect(mockService.callCount == 1) // Should not make additional calls
    }
    
    @Test func testLoadMoreRepositoriesWithNonExistentRepository() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        // Setup response with repositories
        let repositories = MockGitHubService.createMockRepositories(count: 10, forUser: "testuser")
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(repositories))
        
        // Load repositories
        await viewModel.loadRepositories()
        #expect(viewModel.repositories.count == 10)
        
        // Create a repository that doesn't exist in the loaded repositories
        let nonExistentRepository = GitHubRepository(
            id: 999, name: "non-existent", fullName: "testuser/non-existent", description: "Non-existent repo",
            language: "Swift", stargazersCount: 0, forksCount: 0, openIssuesCount: 0,
            size: 1024, defaultBranch: "main", visibility: "public", fork: false,
            htmlUrl: "https://github.com/testuser/non-existent", cloneUrl: "https://github.com/testuser/non-existent.git",
            createdAt: "2020-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z", pushedAt: "2023-01-01T00:00:00Z",
            owner: testUser
        )
        
        // This should not crash even with non-existent repository
        await viewModel.loadMoreRepositoriesIfNeeded(currentRepository: nonExistentRepository)
        #expect(viewModel.repositories.count == 10) // Should remain unchanged
        #expect(mockService.callCount == 1) // Should not make additional calls
    }
    

    
    // MARK: - Navigation Tests
    
    @Test func testOpenRepositoryInWebView() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let testRepository = GitHubRepository(
            id: 1, name: "test-repo", fullName: "testuser/test-repo", description: "Test repo",
            language: "Swift", stargazersCount: 10, forksCount: 2, openIssuesCount: 1,
            size: 1024, defaultBranch: "main", visibility: "public", fork: false,
            htmlUrl: "https://github.com/testuser/test-repo", cloneUrl: "https://github.com/testuser/test-repo.git",
            createdAt: "2020-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z", pushedAt: "2023-01-01T00:00:00Z",
            owner: testUser
        )
        
        viewModel.selectRepository(testRepository)
        
        #expect(mockRouter.navigationCount == 1)
        #expect(mockRouter.wasRouteCalled(.repositoryWebView(URL(string: "https://github.com/testuser/test-repo")!)))
        
        let lastNavigation = mockRouter.getLastNavigation()
        if case .repositoryWebView(let url) = lastNavigation?.route {
            #expect(url.absoluteString == "https://github.com/testuser/test-repo")
        } else {
            Issue.record("Expected repositoryWebView route")
        }
    }
    
    @Test func testOpenRepositoryWithInvalidURL() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let testRepository = GitHubRepository(
            id: 1, name: "test-repo", fullName: "testuser/test-repo", description: "Test repo",
            language: "Swift", stargazersCount: 10, forksCount: 2, openIssuesCount: 1,
            size: 1024, defaultBranch: "main", visibility: "public", fork: false,
            htmlUrl: "invalid-url", cloneUrl: "https://github.com/testuser/test-repo.git",
            createdAt: "2020-01-01T00:00:00Z", updatedAt: "2023-01-01T00:00:00Z", pushedAt: "2023-01-01T00:00:00Z",
            owner: testUser
        )
        
        viewModel.selectRepository(testRepository)
        
        // Should not navigate if URL is invalid
        #expect(mockRouter.navigationCount == 0)
    }
    
    // MARK: - Error Handling Tests
    
    @Test func testClearError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .failure(.networkError(NSError(domain: "Test", code: -1, userInfo: nil))))
        
        // Trigger error
        await viewModel.loadRepositories()
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
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let testErrorMessage = "Test error message"
        viewModel.showError(testErrorMessage)
        
        #expect(viewModel.hasError == true)
        #expect(viewModel.errorMessage == testErrorMessage)
    }
    
    // MARK: - Refresh Tests
    
    @Test func testRefreshData() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let detailedUser = testUser
        let mockRepositories = MockGitHubService.createMockRepositories(count: 2, forUser: "testuser")
        
        mockService.mockUserDetails(username: "testuser", response: .success(detailedUser))
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(mockRepositories))
        
        await viewModel.refreshData()
        
        #expect(viewModel.repositories.count == 2)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("getUserDetails"))
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
        #expect(mockService.callCount == 2)
    }
    
    @Test func testRefreshDataWithError() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        mockService.mockUserDetails(username: "testuser", response: .failure(.serverError(500)))
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .failure(.serverError(500)))
        
        await viewModel.refreshData()
        
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
        #expect(mockService.wasMethodCalled("getUserDetails"))
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
        #expect(mockService.callCount == 2)
    }
    
    // MARK: - Concurrent Operations Tests
    
    @Test func testConcurrentLoadOperations() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        // Create view model first
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let detailedUser = testUser
        let mockRepositories = MockGitHubService.createMockRepositories(count: 1, forUser: "testuser")
        
        mockService.mockUserDetails(username: "testuser", response: .success(detailedUser))
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(mockRepositories))
        
        // Start multiple concurrent operations
        async let userDetails = viewModel.loadUserDetails()
        async let repositories = viewModel.loadRepositories()
        async let refresh = viewModel.refreshData()
        
        await userDetails
        await repositories
        await refresh
        
        #expect(viewModel.repositories.count == 1)
        #expect(mockService.callCount >= 1) // At least user details and repositories
    }
    
    // MARK: - State Management Tests
    
    @Test func testLoadingStateManagement() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        let mockRepositories = MockGitHubService.createMockRepositories(count: 1, forUser: "testuser")
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success(mockRepositories))
        
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        let loadTask = Task {
            await viewModel.loadRepositories()
        }
        
        await loadTask.value
        
        #expect(viewModel.repositories.count == 1)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func testUserWithoutRepositories() async throws {
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        mockService.mockUserNonForkedRepositories(username: "testuser", page: 1, perPage: 20, response: .success([]))
        
        let viewModel = createViewModel(user: testUser, mockService: mockService, mockRouter: mockRouter)
        
        await viewModel.loadRepositories()
        
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(mockService.wasMethodCalled("getUserNonForkedRepositories"))
    }
    
    @Test func testUserWithMinimalProfile() async throws {
        let minimalUser = GitHubUser(
            id: 2,
            login: "minimaluser",
            avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4",
            type: "User",
            siteAdmin: false
        )
        
        let mockService = MockGitHubService()
        let mockRouter = MockRouter()
        
        mockService.mockUserDetails(username: "minimaluser", response: .success(minimalUser))
        mockService.mockUserNonForkedRepositories(username: "minimaluser", page: 1, perPage: 20, response: .success([]))
        
        let viewModel = createViewModel(user: minimalUser, mockService: mockService, mockRouter: mockRouter)
        
        await viewModel.loadUserDetails()
        await viewModel.loadRepositories()
        
        #expect(viewModel.user.login == "minimaluser")
        #expect(viewModel.user.name == nil)
        #expect(viewModel.user.company == nil)
        #expect(viewModel.repositories.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }
} 
