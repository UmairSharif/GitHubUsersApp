import Testing
import Foundation
import SwiftUI
@testable import GitHubUsersApp

@MainActor
struct RouterTests {
    
    // MARK: - Test Setup
    
    private func createRouter() -> Router {
        return Router()
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
        let router = createRouter()
        
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    // MARK: - Navigation Tests
    
    @Test func testNavigateToUserList() async throws {
        let router = createRouter()
        
        router.navigate(to: .userList)
        
        #expect(router.path.count == 1)
    }
    
    @Test func testNavigateToUserDetail() async throws {
        let router = createRouter()
        
        router.navigate(to: .userDetail(testUser))
        
        #expect(router.path.count == 1)
    }
    
    @Test func testNavigateToRepositoryWebView() async throws {
        let router = createRouter()
        let testURL = URL(string: "https://github.com/testuser/test-repo")!
        
        router.navigate(to: .repositoryWebView(testURL))
        
        #expect(router.path.count == 1)
    }
    
    @Test func testNavigateToAPIKeyConfig() async throws {
        let router = createRouter()
        
        router.navigate(to: .apiKeyConfig)
        
        #expect(router.path.count == 1)
    }
    
    @Test func testMultipleNavigations() async throws {
        let router = createRouter()
        
        router.navigate(to: .userList)
        #expect(router.path.count == 1)
        
        router.navigate(to: .userDetail(testUser))
        #expect(router.path.count == 2)
        
        let testURL = URL(string: "https://github.com/testuser/test-repo")!
        router.navigate(to: .repositoryWebView(testURL))
        #expect(router.path.count == 3)
        
        router.navigate(to: .apiKeyConfig)
        #expect(router.path.count == 4)
    }
    
    // MARK: - Back Navigation Tests
    
    @Test func testNavigateBack() async throws {
        let router = createRouter()
        
        // Navigate to multiple screens
        router.navigate(to: .userList)
        router.navigate(to: .userDetail(testUser))
        router.navigate(to: .apiKeyConfig)
        #expect(router.path.count == 3)
        
        // Navigate back
        router.navigateBack()
        #expect(router.path.count == 2)
        
        router.navigateBack()
        #expect(router.path.count == 1)
        
        router.navigateBack()
        #expect(router.path.count == 0)
    }
    
    @Test func testNavigateBackFromEmptyPath() async throws {
        let router = createRouter()
        
        #expect(router.path.isEmpty)
        
        // Should not crash when trying to navigate back from empty path
        router.navigateBack()
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    @Test func testNavigateBackFromSingleItem() async throws {
        let router = createRouter()
        
        router.navigate(to: .userList)
        #expect(router.path.count == 1)
        
        router.navigateBack()
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    // MARK: - Root Navigation Tests
    
    @Test func testNavigateToRoot() async throws {
        let router = createRouter()
        
        // Navigate to multiple screens
        router.navigate(to: .userList)
        router.navigate(to: .userDetail(testUser))
        router.navigate(to: .apiKeyConfig)
        #expect(router.path.count == 3)
        
        // Navigate to root
        router.navigateToRoot()
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    @Test func testNavigateToRootFromEmptyPath() async throws {
        let router = createRouter()
        
        #expect(router.path.isEmpty)
        
        // Should not crash when trying to navigate to root from empty path
        router.navigateToRoot()
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    @Test func testNavigateToRootFromSingleItem() async throws {
        let router = createRouter()
        
        router.navigate(to: .userList)
        #expect(router.path.count == 1)
        
        router.navigateToRoot()
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    // MARK: - Route Equality Tests
    
    @Test func testRouteEquality() async throws {
        let user1 = GitHubUser(id: 1, login: "user1", avatarUrl: "https://example.com/1", type: "User", siteAdmin: false)
        let user2 = GitHubUser(id: 2, login: "user2", avatarUrl: "https://example.com/2", type: "User", siteAdmin: false)
        let url1 = URL(string: "https://github.com/user1/repo1")!
        let url2 = URL(string: "https://github.com/user2/repo2")!
        
        // Test same routes
        #expect(Route.userList == Route.userList)
        #expect(Route.apiKeyConfig == Route.apiKeyConfig)
        #expect(Route.userDetail(user1) == Route.userDetail(user1))
        #expect(Route.repositoryWebView(url1) == Route.repositoryWebView(url1))
        
        // Test different routes
        #expect(Route.userList != Route.apiKeyConfig)
        #expect(Route.userDetail(user1) != Route.userDetail(user2))
        #expect(Route.repositoryWebView(url1) != Route.repositoryWebView(url2))
        #expect(Route.userList != Route.userDetail(user1))
        #expect(Route.userDetail(user1) != Route.repositoryWebView(url1))
    }
    
    @Test func testRouteHashable() async throws {
        let user = GitHubUser(id: 1, login: "user1", avatarUrl: "https://example.com/1", type: "User", siteAdmin: false)
        let url = URL(string: "https://github.com/user1/repo1")!
        
        let routes: Set<Route> = [
            .userList,
            .apiKeyConfig,
            .userDetail(user),
            .repositoryWebView(url)
        ]
        
        #expect(routes.count == 4)
        #expect(routes.contains(.userList))
        #expect(routes.contains(.apiKeyConfig))
        #expect(routes.contains(.userDetail(user)))
        #expect(routes.contains(.repositoryWebView(url)))
    }
    
    // MARK: - Complex Navigation Scenarios
    
    @Test func testComplexNavigationFlow() async throws {
        let router = createRouter()
        
        // Start with user list
        router.navigate(to: .userList)
        #expect(router.path.count == 1)
        
        // Navigate to user detail
        router.navigate(to: .userDetail(testUser))
        #expect(router.path.count == 2)
        
        // Navigate to repository
        let repoURL = URL(string: "https://github.com/testuser/test-repo")!
        router.navigate(to: .repositoryWebView(repoURL))
        #expect(router.path.count == 3)
        
        // Go back to user detail
        router.navigateBack()
        #expect(router.path.count == 2)
        
        // Navigate to API config
        router.navigate(to: .apiKeyConfig)
        #expect(router.path.count == 3)
        
        // Go back to root
        router.navigateToRoot()
        #expect(router.path.isEmpty)
    }
    
    @Test func testNavigationWithSameRouteMultipleTimes() async throws {
        let router = createRouter()
        
        // Navigate to same route multiple times
        router.navigate(to: .userList)
        #expect(router.path.count == 1)
        
        router.navigate(to: .userList)
        #expect(router.path.count == 2)
        
        router.navigate(to: .userList)
        #expect(router.path.count == 3)
        
        // Navigate back should remove one at a time
        router.navigateBack()
        #expect(router.path.count == 2)
        
        router.navigateBack()
        #expect(router.path.count == 1)
        
        router.navigateBack()
        #expect(router.path.count == 0)
    }
    
    @Test func testNavigationWithDifferentUsers() async throws {
        let router = createRouter()
        
        let user1 = GitHubUser(id: 1, login: "user1", avatarUrl: "https://example.com/1", type: "User", siteAdmin: false)
        let user2 = GitHubUser(id: 2, login: "user2", avatarUrl: "https://example.com/2", type: "User", siteAdmin: false)
        
        router.navigate(to: .userDetail(user1))
        #expect(router.path.count == 1)
        
        router.navigate(to: .userDetail(user2))
        #expect(router.path.count == 2)
        
        router.navigate(to: .userDetail(user1))
        #expect(router.path.count == 3)
        
        router.navigateToRoot()
        #expect(router.path.isEmpty)
    }
    
    @Test func testNavigationWithDifferentURLs() async throws {
        let router = createRouter()
        
        let url1 = URL(string: "https://github.com/user1/repo1")!
        let url2 = URL(string: "https://github.com/user2/repo2")!
        let url3 = URL(string: "https://github.com/user1/repo3")!
        
        router.navigate(to: .repositoryWebView(url1))
        #expect(router.path.count == 1)
        
        router.navigate(to: .repositoryWebView(url2))
        #expect(router.path.count == 2)
        
        router.navigate(to: .repositoryWebView(url3))
        #expect(router.path.count == 3)
        
        router.navigateBack()
        #expect(router.path.count == 2)
        
        router.navigateBack()
        #expect(router.path.count == 1)
        
        router.navigateBack()
        #expect(router.path.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    @Test func testMultipleBackNavigationsFromEmpty() async throws {
        let router = createRouter()
        
        #expect(router.path.isEmpty)
        
        // Multiple back navigations should not crash
        router.navigateBack()
        router.navigateBack()
        router.navigateBack()
        
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    @Test func testMultipleRootNavigationsFromEmpty() async throws {
        let router = createRouter()
        
        #expect(router.path.isEmpty)
        
        // Multiple root navigations should not crash
        router.navigateToRoot()
        router.navigateToRoot()
        router.navigateToRoot()
        
        #expect(router.path.isEmpty)
        #expect(router.path.count == 0)
    }
    
    @Test func testMixedNavigationOperations() async throws {
        let router = createRouter()
        
        // Mix of different operations
        router.navigate(to: .userList)
        router.navigateBack()
        router.navigate(to: .apiKeyConfig)
        router.navigateToRoot()
        router.navigate(to: .userDetail(testUser))
        router.navigate(to: .userList)
        router.navigateBack()
        router.navigateBack()
        
        #expect(router.path.isEmpty)
    }
    
    // MARK: - State Consistency Tests
    
    @Test func testPathConsistencyAfterOperations() async throws {
        let router = createRouter()
        
        // Verify path count consistency
        #expect(router.path.count == 0)
        #expect(router.path.isEmpty == true)
        
        router.navigate(to: .userList)
        #expect(router.path.count == 1)
        #expect(router.path.isEmpty == false)
        
        router.navigate(to: .apiKeyConfig)
        #expect(router.path.count == 2)
        #expect(router.path.isEmpty == false)
        
        router.navigateBack()
        #expect(router.path.count == 1)
        #expect(router.path.isEmpty == false)
        
        router.navigateToRoot()
        #expect(router.path.count == 0)
        #expect(router.path.isEmpty == true)
    }
} 