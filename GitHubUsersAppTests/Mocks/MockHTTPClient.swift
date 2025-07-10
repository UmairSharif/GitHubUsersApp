import Foundation
@testable import GitHubUsersApp

final class MockHTTPClient: HTTPClient {
    
    // MARK: - Mock Configuration
    private var mockResponses: [String: Result<Data, NetworkError>] = [:]
    private var callHistory: [MockCall] = []
    
    struct MockCall {
        let endpoint: Endpoint
        let timestamp: Date
        let responseModel: String
    }
    
    // MARK: - Public Interface
    func mockResponse<T: Codable>(for endpoint: Endpoint, response: T) {
        let key = generateKey(for: endpoint)
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(response)
            mockResponses[key] = .success(data)
        } catch {
            mockResponses[key] = .failure(.networkError(error))
        }
    }
    
    func mockError(for endpoint: Endpoint, error: NetworkError) {
        let key = generateKey(for: endpoint)
        mockResponses[key] = .failure(error)
    }
    
    func clearMocks() {
        mockResponses.removeAll()
        callHistory.removeAll()
    }
    
    // MARK: - Test Helpers
    var callCount: Int {
        return callHistory.count
    }
    
    func wasEndpointCalled(_ endpoint: Endpoint) -> Bool {
        let key = generateKey(for: endpoint)
        return callHistory.contains { generateKey(for: $0.endpoint) == key }
    }
    
    func callsFor(_ endpoint: Endpoint) -> [MockCall] {
        let key = generateKey(for: endpoint)
        return callHistory.filter { generateKey(for: $0.endpoint) == key }
    }
    
    // MARK: - HTTPClient Implementation
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, NetworkError> {
        
        // Record the call
        let call = MockCall(
            endpoint: endpoint,
            timestamp: Date(),
            responseModel: String(describing: responseModel)
        )
        callHistory.append(call)
        
        let key = generateKey(for: endpoint)
        
        // Check if we have a mock response configured
        guard let mockResult = mockResponses[key] else {
            return .failure(.customError("No mock response configured for endpoint: \(endpoint.path)"))
        }
        
        switch mockResult {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(responseModel, from: data)
                return .success(decodedResponse)
            } catch {
                return .failure(.decodingError(error))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Private Helpers
    private func generateKey(for endpoint: Endpoint) -> String {
        var components = [endpoint.method.rawValue, endpoint.path]
        
        if let query = endpoint.query {
            let sortedQuery = query.sorted { $0.key < $1.key }
            let queryString = sortedQuery.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            components.append(queryString)
        }
        
        return components.joined(separator: "|")
    }
}

// MARK: - Mock Data Factory
extension MockHTTPClient {
    
    static func createMockSearchResponse(totalCount: Int = 100, users: [GitHubUser]) -> SearchResponse<GitHubUser> {
        return SearchResponse(
            totalCount: totalCount,
            incompleteResults: false,
            items: users
        )
    }
    
    static func createMockUser(id: Int = 1, login: String = "testuser") -> GitHubUser {
        return GitHubUser(
            id: id,
            login: login,
            avatarUrl: "https://avatars.githubusercontent.com/u/\(id)?v=4",
            type: "User",
            siteAdmin: false,
            name: "Test User \(id)",
            company: "Test Company",
            blog: "https://blog.test.com",
            location: "Test City",
            email: "test@example.com",
            bio: "Test bio for user \(id)",
            publicRepos: 10,
            publicGists: 5,
            followers: 100,
            following: 50,
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z"
        )
    }
    
    static func createMockRepository(id: Int = 1, name: String = "test-repo", fork: Bool = false) -> GitHubRepository {
        return GitHubRepository(
            id: id,
            name: name,
            fullName: "testuser/\(name)",
            description: "Test repository \(id)",
            language: "Swift",
            stargazersCount: 50,
            forksCount: 10,
            openIssuesCount: 2,
            size: 1024,
            defaultBranch: "main",
            visibility: "public",
            fork: fork,
            htmlUrl: "https://github.com/testuser/\(name)",
            cloneUrl: "https://github.com/testuser/\(name).git",
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z",
            pushedAt: "2023-01-01T00:00:00Z",
            owner: createMockUser()
        )
    }
    
    static func createMockErrorResponse(message: String = "Test error") -> GitHubErrorResponse {
        return GitHubErrorResponse(
            message: message,
            documentationUrl: "https://docs.github.com/rest"
        )
    }
    
    // MARK: - Static Mock Data for Tests
    static let mockUser1 = GitHubUser(
        id: 1,
        login: "testuser1",
        avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
        type: "User",
        siteAdmin: false,
        name: "Test User 1",
        company: "Test Company 1",
        blog: "https://blog1.test.com",
        location: "Test City 1",
        email: "test1@example.com",
        bio: "Test bio for user 1",
        publicRepos: 25,
        publicGists: 10,
        followers: 100,
        following: 50,
        createdAt: "2020-01-01T00:00:00Z",
        updatedAt: "2023-01-01T00:00:00Z"
    )
    
    static let mockUser2 = GitHubUser(
        id: 2,
        login: "testuser2",
        avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4",
        type: "User",
        siteAdmin: false,
        name: "Test User 2",
        company: "Test Company 2",
        blog: "https://blog2.test.com",
        location: "Test City 2",
        email: "test2@example.com",
        bio: "Test bio for user 2",
        publicRepos: 15,
        publicGists: 8,
        followers: 75,
        following: 30,
        createdAt: "2020-02-01T00:00:00Z",
        updatedAt: "2023-02-01T00:00:00Z"
    )
    
    static let mockRepository1 = GitHubRepository(
        id: 1,
        name: "test-repo-1",
        fullName: "testuser1/test-repo-1",
        description: "First test repository",
        language: "Swift",
        stargazersCount: 100,
        forksCount: 20,
        openIssuesCount: 5,
        size: 2048,
        defaultBranch: "main",
        visibility: "public",
        fork: false,
        htmlUrl: "https://github.com/testuser1/test-repo-1",
        cloneUrl: "https://github.com/testuser1/test-repo-1.git",
        createdAt: "2020-01-01T00:00:00Z",
        updatedAt: "2023-01-01T00:00:00Z",
        pushedAt: "2023-01-01T00:00:00Z",
        owner: mockUser1
    )
    
    static let mockRepository2 = GitHubRepository(
        id: 2,
        name: "test-repo-2",
        fullName: "testuser1/test-repo-2",
        description: "Second test repository",
        language: "TypeScript",
        stargazersCount: 75,
        forksCount: 15,
        openIssuesCount: 3,
        size: 1536,
        defaultBranch: "main",
        visibility: "public",
        fork: false,
        htmlUrl: "https://github.com/testuser1/test-repo-2",
        cloneUrl: "https://github.com/testuser1/test-repo-2.git",
        createdAt: "2020-02-01T00:00:00Z",
        updatedAt: "2023-02-01T00:00:00Z",
        pushedAt: "2023-02-01T00:00:00Z",
        owner: mockUser1
    )
} 