import Foundation
import SwiftUI
@testable import GitHubUsersApp

final class MockRouter: RouterProtocol {
    
    // MARK: - RouterProtocol Implementation
    @Published var path = NavigationPath()
    
    // MARK: - Mock Configuration
    private var navigationHistory: [NavigationCall] = []
    
    struct NavigationCall {
        let route: Route
        let timestamp: Date
    }
    
    // MARK: - Test Helpers
    var navigationCount: Int {
        return navigationHistory.count
    }
    
    func wasRouteCalled(_ route: Route) -> Bool {
        return navigationHistory.contains { $0.route == route }
    }
    
    func getLastNavigation() -> NavigationCall? {
        return navigationHistory.last
    }
    
    func clearNavigationHistory() {
        navigationHistory.removeAll()
        path = NavigationPath()
    }
    
    func navigationsFor(_ route: Route) -> [NavigationCall] {
        return navigationHistory.filter { $0.route == route }
    }
    
    // MARK: - RouterProtocol Implementation
    func navigate(to route: Route) {
        let call = NavigationCall(
            route: route,
            timestamp: Date()
        )
        navigationHistory.append(call)
        
        // Actually update the path for testing
        path.append(route)
    }
    
    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
} 