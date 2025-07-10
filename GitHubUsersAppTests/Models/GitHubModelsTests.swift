import Testing
import Foundation
@testable import GitHubUsersApp

struct GitHubModelsTests {
    
    // MARK: - GitHubUser Tests
    
    @Test func testGitHubUserDecoding() async throws {
        let json = """
        {
            "id": 1,
            "login": "octocat",
            "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
            "type": "User",
            "site_admin": false,
            "name": "The Octocat",
            "company": "GitHub",
            "blog": "https://github.blog",
            "location": "San Francisco",
            "email": "octocat@github.com",
            "bio": "There once was...",
            "public_repos": 8,
            "public_gists": 8,
            "followers": 9999,
            "following": 9,
            "created_at": "2008-01-14T04:33:35Z",
            "updated_at": "2008-01-14T04:33:35Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let user = try decoder.decode(GitHubUser.self, from: data)
        
        #expect(user.id == 1)
        #expect(user.login == "octocat")
        #expect(user.avatarUrl == "https://avatars.githubusercontent.com/u/1?v=4")
        #expect(user.type == "User")
        #expect(user.siteAdmin == false)
        #expect(user.name == "The Octocat")
        #expect(user.company == "GitHub")
        #expect(user.blog == "https://github.blog")
        #expect(user.location == "San Francisco")
        #expect(user.email == "octocat@github.com")
        #expect(user.bio == "There once was...")
        #expect(user.publicRepos == 8)
        #expect(user.publicGists == 8)
        #expect(user.followers == 9999)
        #expect(user.following == 9)
        #expect(user.createdAt == "2008-01-14T04:33:35Z")
        #expect(user.updatedAt == "2008-01-14T04:33:35Z")
    }
    
    @Test func testGitHubUserMinimalDecoding() async throws {
        let json = """
        {
            "id": 1,
            "login": "octocat",
            "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
            "type": "User",
            "site_admin": false
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let user = try decoder.decode(GitHubUser.self, from: data)
        
        #expect(user.id == 1)
        #expect(user.login == "octocat")
        #expect(user.avatarUrl == "https://avatars.githubusercontent.com/u/1?v=4")
        #expect(user.type == "User")
        #expect(user.siteAdmin == false)
        #expect(user.name == nil)
        #expect(user.company == nil)
        #expect(user.blog == nil)
        #expect(user.location == nil)
        #expect(user.email == nil)
        #expect(user.bio == nil)
        #expect(user.publicRepos == nil)
        #expect(user.publicGists == nil)
        #expect(user.followers == nil)
        #expect(user.following == nil)
        #expect(user.createdAt == nil)
        #expect(user.updatedAt == nil)
    }
    
    @Test func testGitHubUserDisplayName() async throws {
        let userWithName = GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false,
            name: "The Octocat"
        )
        
        let userWithoutName = GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false
        )
        
        #expect(userWithName.displayName == "The Octocat")
        #expect(userWithoutName.displayName == "octocat")
    }
    
    @Test func testGitHubUserAvatarURL() async throws {
        let user = GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false
        )
        
        let invalidUser = GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "invalid-url",
            type: "User",
            siteAdmin: false
        )
        
        #expect(user.avatarURL?.absoluteString == "https://avatars.githubusercontent.com/u/1?v=4")
        #expect(invalidUser.avatarURL == nil)
    }
    
    @Test func testGitHubUserEquality() async throws {
        let user1 = GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false
        )
        
        let user2 = GitHubUser(
            id: 1,
            login: "octocat",
            avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
            type: "User",
            siteAdmin: false
        )
        
        let user3 = GitHubUser(
            id: 2,
            login: "different",
            avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4",
            type: "User",
            siteAdmin: false
        )
        
        #expect(user1 == user2)
        #expect(user1 != user3)
        #expect(user1.hashValue == user2.hashValue)
        #expect(user1.hashValue != user3.hashValue)
    }
    
    @Test func testGitHubUserMock() async throws {
        let mockUser = GitHubUser.mock
        
        #expect(mockUser.id == 1)
        #expect(mockUser.login == "octocat")
        #expect(mockUser.avatarUrl == "https://avatars.githubusercontent.com/u/1?v=4")
        #expect(mockUser.type == "User")
        #expect(mockUser.siteAdmin == false)
    }
    
    // MARK: - GitHubRepository Tests
    
    @Test func testGitHubRepositoryDecoding() async throws {
        let json = """
        {
            "id": 1,
            "name": "Hello-World",
            "full_name": "octocat/Hello-World",
            "description": "This your first repo!",
            "language": "Swift",
            "stargazers_count": 80,
            "forks_count": 9,
            "open_issues_count": 0,
            "size": 108,
            "default_branch": "master",
            "visibility": "public",
            "fork": false,
            "html_url": "https://github.com/octocat/Hello-World",
            "clone_url": "https://github.com/octocat/Hello-World.git",
            "created_at": "2011-01-26T19:01:12Z",
            "updated_at": "2011-01-26T19:14:43Z",
            "pushed_at": "2011-01-26T19:06:43Z",
            "owner": {
                "id": 1,
                "login": "octocat",
                "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
                "type": "User",
                "site_admin": false
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let repository = try decoder.decode(GitHubRepository.self, from: data)
        
        #expect(repository.id == 1)
        #expect(repository.name == "Hello-World")
        #expect(repository.fullName == "octocat/Hello-World")
        #expect(repository.description == "This your first repo!")
        #expect(repository.language == "Swift")
        #expect(repository.stargazersCount == 80)
        #expect(repository.forksCount == 9)
        #expect(repository.openIssuesCount == 0)
        #expect(repository.size == 108)
        #expect(repository.defaultBranch == "master")
        #expect(repository.visibility == "public")
        #expect(repository.fork == false)
        #expect(repository.htmlUrl == "https://github.com/octocat/Hello-World")
        #expect(repository.cloneUrl == "https://github.com/octocat/Hello-World.git")
        #expect(repository.createdAt == "2011-01-26T19:01:12Z")
        #expect(repository.updatedAt == "2011-01-26T19:14:43Z")
        #expect(repository.pushedAt == "2011-01-26T19:06:43Z")
        #expect(repository.owner.login == "octocat")
    }
    
    @Test func testGitHubRepositoryWithNullValues() async throws {
        let json = """
        {
            "id": 1,
            "name": "Hello-World",
            "full_name": "octocat/Hello-World",
            "description": null,
            "language": null,
            "stargazers_count": 80,
            "forks_count": 9,
            "open_issues_count": 0,
            "size": 108,
            "default_branch": "master",
            "visibility": "public",
            "fork": false,
            "html_url": "https://github.com/octocat/Hello-World",
            "clone_url": "https://github.com/octocat/Hello-World.git",
            "created_at": "2011-01-26T19:01:12Z",
            "updated_at": "2011-01-26T19:14:43Z",
            "pushed_at": null,
            "owner": {
                "id": 1,
                "login": "octocat",
                "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
                "type": "User",
                "site_admin": false
            }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let repository = try decoder.decode(GitHubRepository.self, from: data)
        
        #expect(repository.description == nil)
        #expect(repository.language == nil)
        #expect(repository.pushedAt == nil)
    }
    
    @Test func testGitHubRepositoryComputedProperties() async throws {
        let repositoryWithDescription = GitHubRepository(
            id: 1,
            name: "test-repo",
            fullName: "octocat/test-repo",
            description: "Test repository",
            language: "Swift",
            stargazersCount: 10,
            forksCount: 5,
            openIssuesCount: 1,
            size: 100,
            defaultBranch: "main",
            visibility: "public",
            fork: false,
            htmlUrl: "https://github.com/octocat/test-repo",
            cloneUrl: "https://github.com/octocat/test-repo.git",
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z",
            pushedAt: "2023-01-01T00:00:00Z",
            owner: GitHubUser.mock
        )
        
        let repositoryWithoutDescription = GitHubRepository(
            id: 1,
            name: "test-repo",
            fullName: "octocat/test-repo",
            description: nil,
            language: nil,
            stargazersCount: 10,
            forksCount: 5,
            openIssuesCount: 1,
            size: 100,
            defaultBranch: "main",
            visibility: "public",
            fork: false,
            htmlUrl: "https://github.com/octocat/test-repo",
            cloneUrl: "https://github.com/octocat/test-repo.git",
            createdAt: "2023-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z",
            pushedAt: "2023-01-01T00:00:00Z",
            owner: GitHubUser.mock
        )
        
        #expect(repositoryWithDescription.displayDescription == "Test repository")
        #expect(repositoryWithoutDescription.displayDescription == "No description available")
        #expect(repositoryWithDescription.displayLanguage == "Swift")
        #expect(repositoryWithoutDescription.displayLanguage == "Unknown")
        #expect(repositoryWithDescription.repositoryURL?.absoluteString == "https://github.com/octocat/test-repo")
    }
    
    @Test func testGitHubRepositoryMock() async throws {
        let mockRepository = GitHubRepository.mock
        
        #expect(mockRepository.id == 1)
        #expect(mockRepository.name == "awesome-swift")
        #expect(mockRepository.fullName == "octocat/awesome-swift")
        #expect(mockRepository.description == "A curated list of awesome Swift libraries and resources")
        #expect(mockRepository.language == "Swift")
        #expect(mockRepository.stargazersCount == 1234)
        #expect(mockRepository.forksCount == 567)
        #expect(mockRepository.fork == false)
        #expect(mockRepository.owner.login == "octocat")
    }
    
    // MARK: - SearchResponse Tests
    
    @Test func testSearchResponseDecoding() async throws {
        let json = """
        {
            "total_count": 12,
            "incomplete_results": false,
            "items": [
                {
                    "id": 1,
                    "login": "octocat",
                    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
                    "type": "User",
                    "site_admin": false
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let searchResponse = try decoder.decode(SearchResponse<GitHubUser>.self, from: data)
        
        #expect(searchResponse.totalCount == 12)
        #expect(searchResponse.incompleteResults == false)
        #expect(searchResponse.items.count == 1)
        #expect(searchResponse.items.first?.login == "octocat")
    }
    
    @Test func testSearchResponseWithEmptyItems() async throws {
        let json = """
        {
            "total_count": 0,
            "incomplete_results": false,
            "items": []
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let searchResponse = try decoder.decode(SearchResponse<GitHubUser>.self, from: data)
        
        #expect(searchResponse.totalCount == 0)
        #expect(searchResponse.incompleteResults == false)
        #expect(searchResponse.items.isEmpty)
    }
    
    // MARK: - GitHubErrorResponse Tests
    
    @Test func testGitHubErrorResponseDecoding() async throws {
        let json = """
        {
            "message": "Not Found",
            "documentation_url": "https://docs.github.com/rest/reference/users#get-a-user"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let errorResponse = try decoder.decode(GitHubErrorResponse.self, from: data)
        
        #expect(errorResponse.message == "Not Found")
        #expect(errorResponse.documentationUrl == "https://docs.github.com/rest/reference/users#get-a-user")
    }
    
    @Test func testGitHubErrorResponseWithoutDocumentationUrl() async throws {
        let json = """
        {
            "message": "Bad credentials"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let errorResponse = try decoder.decode(GitHubErrorResponse.self, from: data)
        
        #expect(errorResponse.message == "Bad credentials")
        #expect(errorResponse.documentationUrl == nil)
    }
    
    // MARK: - RateLimitInfo Tests
    
    @Test func testRateLimitInfo() async throws {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        let rateLimitInfo = RateLimitInfo(limit: 5000, remaining: 4999, reset: futureDate)
        
        #expect(rateLimitInfo.limit == 5000)
        #expect(rateLimitInfo.remaining == 4999)
        #expect(rateLimitInfo.reset == futureDate)
        #expect(rateLimitInfo.isExceeded == false)
        #expect(!rateLimitInfo.resetTimeString.isEmpty)
    }
    
    @Test func testRateLimitInfoExceeded() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let rateLimitInfo = RateLimitInfo(limit: 5000, remaining: 0, reset: futureDate)
        
        #expect(rateLimitInfo.isExceeded == true)
    }
    
    // MARK: - Edge Cases and Error Handling
    
    @Test func testInvalidJSONDecoding() async throws {
        let invalidJson = """
        {
            "id": "not-a-number",
            "login": "octocat"
        }
        """
        
        let data = invalidJson.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        #expect(throws: DecodingError.self) {
            try decoder.decode(GitHubUser.self, from: data)
        }
    }
    
    @Test func testMissingRequiredFields() async throws {
        let incompleteJson = """
        {
            "login": "octocat"
        }
        """
        
        let data = incompleteJson.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        #expect(throws: DecodingError.self) {
            try decoder.decode(GitHubUser.self, from: data)
        }
    }
} 