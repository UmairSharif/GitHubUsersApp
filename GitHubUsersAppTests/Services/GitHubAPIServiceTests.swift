import Testing
import Foundation
@testable import GitHubUsersApp

struct GitHubAPIServiceTests {
    
    // MARK: - Test Setup
    
    private func setupTest() {
        // Clear any shared state that might affect tests
        UserDefaults.standard.removeObject(forKey: "GitHubAPIKey")
    }
    
    private func createGitHubService(with mockHTTPClient: MockHTTPClient) -> GitHubService {
        setupTest() // Clear state before each test
        mockHTTPClient.clearMocks() // Clear mock state
        return GitHubService(httpClient: mockHTTPClient)
    }
    
    // MARK: - Search Users Tests
    
    @Test func testSearchUsersSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockUsers = [
            MockHTTPClient.createMockUser(id: 1, login: "user1"),
            MockHTTPClient.createMockUser(id: 2, login: "user2")
        ]
        let mockResponse = MockHTTPClient.createMockSearchResponse(totalCount: 2, users: mockUsers)
        
        let endpoint = AppEndpoints.searchUsers(query: "test", page: 1, perPage: 10)
        mockHTTPClient.mockResponse(for: endpoint, response: mockResponse)
        
        let result = await service.searchUsers(query: "test", page: 1, perPage: 10)
        
        switch result {
        case .success(let response):
            #expect(response.totalCount == 2)
            #expect(response.items.count == 2)
            #expect(response.items[0].login == "user1")
            #expect(response.items[1].login == "user2")
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testSearchUsersWithEmptyQuery() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockUsers = [MockHTTPClient.createMockUser()]
        let mockResponse = MockHTTPClient.createMockSearchResponse(totalCount: 1, users: mockUsers)
        
        // Empty query should default to "a"
        let endpoint = AppEndpoints.searchUsers(query: "a", page: 1, perPage: 10)
        mockHTTPClient.mockResponse(for: endpoint, response: mockResponse)
        
        let result = await service.searchUsers(query: "", page: 1, perPage: 10)
        
        switch result {
        case .success(let response):
            #expect(response.totalCount == 1)
            #expect(response.items.count == 1)
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testSearchUsersNetworkError() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.searchUsers(query: "test", page: 1, perPage: 10)
        mockHTTPClient.mockError(for: endpoint, error: .networkError(NSError(domain: "Test", code: -1, userInfo: nil)))
        
        let result = await service.searchUsers(query: "test", page: 1, perPage: 10)
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .networkError = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected networkError, got: \(error)")
            }
        }
    }
    
    @Test func testSearchUsersRateLimitExceeded() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.searchUsers(query: "test", page: 1, perPage: 10)
        mockHTTPClient.mockError(for: endpoint, error: .rateLimitExceeded)
        
        let result = await service.searchUsers(query: "test", page: 1, perPage: 10)
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .rateLimitExceeded = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected rateLimitExceeded, got: \(error)")
            }
        }
    }
    
    @Test func testSearchUsersPagination() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockUsers = [MockHTTPClient.createMockUser()]
        let mockResponse = MockHTTPClient.createMockSearchResponse(totalCount: 100, users: mockUsers)
        
        let endpoint = AppEndpoints.searchUsers(query: "test", page: 2, perPage: 20)
        mockHTTPClient.mockResponse(for: endpoint, response: mockResponse)
        
        let result = await service.searchUsers(query: "test", page: 2, perPage: 20)
        
        switch result {
        case .success(let response):
            #expect(response.totalCount == 100)
            #expect(response.items.count == 1)
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Get User Details Tests
    
    @Test func testGetUserDetailsSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockUser = MockHTTPClient.createMockUser(id: 1, login: "testuser")
        
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        mockHTTPClient.mockResponse(for: endpoint, response: mockUser)
        
        let result = await service.getUserDetails(username: "testuser")
        
        switch result {
        case .success(let user):
            #expect(user.id == 1)
            #expect(user.login == "testuser")
            #expect(user.name == "Test User 1")
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testGetUserDetailsNotFound() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserDetails(username: "nonexistent")
        mockHTTPClient.mockError(for: endpoint, error: .customError("Not Found"))
        
        let result = await service.getUserDetails(username: "nonexistent")
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .customError(let message) = error {
                #expect(message == "Not Found")
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected customError, got: \(error)")
            }
        }
    }
    
    @Test func testGetUserDetailsDecodingError() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        mockHTTPClient.mockError(for: endpoint, error: .decodingError(NSError(domain: "DecodingError", code: -1, userInfo: nil)))
        
        let result = await service.getUserDetails(username: "testuser")
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .decodingError = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected decodingError, got: \(error)")
            }
        }
    }
    
    // MARK: - Get User Repositories Tests
    
    @Test func testGetUserRepositoriesSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockRepositories = [
            MockHTTPClient.createMockRepository(id: 1, name: "repo1"),
            MockHTTPClient.createMockRepository(id: 2, name: "repo2")
        ]
        
        let endpoint = AppEndpoints.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        mockHTTPClient.mockResponse(for: endpoint, response: mockRepositories)
        
        let result = await service.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        
        switch result {
        case .success(let repositories):
            #expect(repositories.count == 2)
            #expect(repositories[0].name == "repo1")
            #expect(repositories[1].name == "repo2")
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testGetUserRepositoriesEmpty() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockRepositories: [GitHubRepository] = []
        
        let endpoint = AppEndpoints.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        mockHTTPClient.mockResponse(for: endpoint, response: mockRepositories)
        
        let result = await service.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        
        switch result {
        case .success(let repositories):
            #expect(repositories.isEmpty)
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testGetUserRepositoriesServerError() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        mockHTTPClient.mockError(for: endpoint, error: .serverError(500))
        
        let result = await service.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .serverError(let statusCode) = error {
                #expect(statusCode == 500)
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected serverError, got: \(error)")
            }
        }
    }
    
    // MARK: - Get User Non-Forked Repositories Tests
    
    @Test func testGetUserNonForkedRepositoriesSuccess() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockRepositories = [
            MockHTTPClient.createMockRepository(id: 1, name: "repo1", fork: false),
            MockHTTPClient.createMockRepository(id: 2, name: "repo2", fork: true),
            MockHTTPClient.createMockRepository(id: 3, name: "repo3", fork: false)
        ]
        
        let endpoint = AppEndpoints.getUserNonForkedRepositories(username: "testuser", page: 1, perPage: 10)
        mockHTTPClient.mockResponse(for: endpoint, response: mockRepositories)
        
        let result = await service.getUserNonForkedRepositories(username: "testuser", page: 1, perPage: 10)
        
        switch result {
        case .success(let repositories):
            // Should filter out forked repositories
            #expect(repositories.count == 2)
            #expect(repositories[0].name == "repo1")
            #expect(repositories[1].name == "repo3")
            #expect(repositories.allSatisfy { !$0.fork })
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testGetUserNonForkedRepositoriesAllForked() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let mockRepositories = [
            MockHTTPClient.createMockRepository(id: 1, name: "repo1", fork: true),
            MockHTTPClient.createMockRepository(id: 2, name: "repo2", fork: true)
        ]
        
        let endpoint = AppEndpoints.getUserNonForkedRepositories(username: "testuser", page: 1, perPage: 10)
        mockHTTPClient.mockResponse(for: endpoint, response: mockRepositories)
        
        let result = await service.getUserNonForkedRepositories(username: "testuser", page: 1, perPage: 10)
        
        switch result {
        case .success(let repositories):
            #expect(repositories.isEmpty)
            #expect(mockHTTPClient.wasEndpointCalled(endpoint))
        case .failure(let error):
            Issue.record("Expected success, got error: \(error)")
        }
    }
    
    @Test func testGetUserNonForkedRepositoriesNetworkError() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserNonForkedRepositories(username: "testuser", page: 1, perPage: 10)
        mockHTTPClient.mockError(for: endpoint, error: .networkError(NSError(domain: "Test", code: -1, userInfo: nil)))
        
        let result = await service.getUserNonForkedRepositories(username: "testuser", page: 1, perPage: 10)
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .networkError = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected networkError, got: \(error)")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    @Test func testMultipleRequestsWithSameClient() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        // Setup mock responses
        let mockUser = MockHTTPClient.createMockUser(id: 1, login: "testuser")
        let mockRepositories = [MockHTTPClient.createMockRepository(id: 1, name: "repo1")]
        
        let userEndpoint = AppEndpoints.getUserDetails(username: "testuser")
        let repoEndpoint = AppEndpoints.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        
        mockHTTPClient.mockResponse(for: userEndpoint, response: mockUser)
        mockHTTPClient.mockResponse(for: repoEndpoint, response: mockRepositories)
        
        // Make multiple requests
        let userResult = await service.getUserDetails(username: "testuser")
        let repoResult = await service.getUserRepositories(username: "testuser", page: 1, perPage: 10)
        
        // Verify both requests succeeded
        switch userResult {
        case .success(let user):
            #expect(user.login == "testuser")
        case .failure(let error):
            Issue.record("Expected user success, got error: \(error)")
        }
        
        switch repoResult {
        case .success(let repositories):
            #expect(repositories.count == 1)
            #expect(repositories[0].name == "repo1")
        case .failure(let error):
            Issue.record("Expected repo success, got error: \(error)")
        }
        
        // Verify both endpoints were called
        #expect(mockHTTPClient.wasEndpointCalled(userEndpoint))
        #expect(mockHTTPClient.wasEndpointCalled(repoEndpoint))
        #expect(mockHTTPClient.callCount == 2)
    }
    
    @Test func testServiceWithRealHTTPClient() async throws {
        // Test that the service can be initialized with a real HTTPClient
        let realHTTPClient = HTTPClientImpl()
        let service = GitHubService(httpClient: realHTTPClient)
        
        // We can't make real network calls in tests, but we can verify initialization
        #expect(service is GitHubService)
        #expect(service is HTTPClient)
        #expect(service is GitHubServiceProtocol)
    }
    
    // MARK: - Error Handling Tests
    
    @Test func testCancelledRequest() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        mockHTTPClient.mockError(for: endpoint, error: .cancelled)
        
        let result = await service.getUserDetails(username: "testuser")
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .cancelled = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected cancelled, got: \(error)")
            }
        }
    }
    
    @Test func testInvalidURL() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        mockHTTPClient.mockError(for: endpoint, error: .invalidURL)
        
        let result = await service.getUserDetails(username: "testuser")
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .invalidURL = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected invalidURL, got: \(error)")
            }
        }
    }
    
    @Test func testNoData() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        mockHTTPClient.mockError(for: endpoint, error: .noData)
        
        let result = await service.getUserDetails(username: "testuser")
        
        switch result {
        case .success:
            Issue.record("Expected failure, got success")
        case .failure(let error):
            if case .noData = error {
                #expect(mockHTTPClient.wasEndpointCalled(endpoint))
            } else {
                Issue.record("Expected noData, got: \(error)")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    @Test func testConcurrentRequests() async throws {
        let mockHTTPClient = MockHTTPClient()
        
        // Create service first
        let service = createGitHubService(with: mockHTTPClient)
        
        // Setup mock responses for multiple users
        let usernames = ["user1", "user2", "user3", "user4", "user5"]
        for (index, username) in usernames.enumerated() {
            let mockUser = MockHTTPClient.createMockUser(id: index + 1, login: username)
            let endpoint = AppEndpoints.getUserDetails(username: username)
            mockHTTPClient.mockResponse(for: endpoint, response: mockUser)
        }
        
        // Make concurrent requests
        let results = await withTaskGroup(of: Result<GitHubUser, NetworkError>.self) { group in
            for username in usernames {
                group.addTask {
                    await service.getUserDetails(username: username)
                }
            }
            
            var results: [Result<GitHubUser, NetworkError>] = []
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        // Verify all requests succeeded
        #expect(results.count == 5)
        for result in results {
            switch result {
            case .success(let user):
                #expect(usernames.contains(user.login))
            case .failure(let error):
                Issue.record("Expected success, got error: \(error)")
            }
        }
        
        #expect(mockHTTPClient.callCount == 5)
    }
} 