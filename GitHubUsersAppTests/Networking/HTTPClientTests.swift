import XCTest
import Foundation
@testable import GitHubUsersApp

final class HTTPClientTests: XCTestCase {
    
    // MARK: - Test Setup
    
    override func setUp() {
        super.setUp()
        // Reset the mock protocol handler before each test
        MockURLProtocol.reset()
    }
    
    override func tearDown() {
        // Clean up after each test
        MockURLProtocol.reset()
        super.tearDown()
    }
    
    private func createMockSession(data: Data?, response: HTTPURLResponse?, error: Error?) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        // Set the handler with lock protection
        MockURLProtocol.setHandler { request in
            if let error = error {
                throw error
            }
            
            guard let response = response else {
                throw NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response provided"])
            }
            
            return (response, data ?? Data())
        }
        
        return URLSession(configuration: configuration)
    }
    
    private func createHTTPResponse(statusCode: Int = 200, headers: [String: String] = [:]) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: "https://api.github.com/test")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }
    
    // MARK: - Success Cases
    
    func testSuccessfulRequest() async throws {
        let mockUser = MockHTTPClient.createMockUser()
        let userData = try JSONEncoder().encode(mockUser)
        
        let response = createHTTPResponse(statusCode: 200)
        let session = createMockSession(data: userData, response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.login, "testuser")
            XCTAssertEqual(user.id, 1)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testSuccessfulRequestWithCustomDecoder() async throws {
        let mockUser = MockHTTPClient.createMockUser()
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let userData = try encoder.encode(mockUser)
        
        let response = createHTTPResponse(statusCode: 200)
        let session = createMockSession(data: userData, response: response, error: nil)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let httpClient = HTTPClientImpl(session: session, decoder: decoder)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.login, "testuser")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testSuccessfulRequestWithRateLimitHeaders() async throws {
        let mockUser = MockHTTPClient.createMockUser()
        let userData = try JSONEncoder().encode(mockUser)
        
        let headers = [
            "X-RateLimit-Limit": "5000",
            "X-RateLimit-Remaining": "4999"
        ]
        let response = createHTTPResponse(statusCode: 200, headers: headers)
        let session = createMockSession(data: userData, response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.login, "testuser")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Error Cases
    
    func testInvalidURL() async throws {
        let session = createMockSession(data: nil, response: nil, error: URLError(.badURL))
        let httpClient = HTTPClientImpl(session: session)
        let invalidEndpoint = TestEndpoint(
            baseUrl: URL(string: "invalid-url")!,
            path: "",
            method: .get,
            header: nil,
            body: nil,
            query: nil
        )
        let result = await httpClient.sendRequest(endpoint: invalidEndpoint, responseModel: GitHubUser.self)
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .networkError = error {
                // Expected - URLSession treats malformed URLs as network errors
            } else {
                XCTFail("Expected networkError, got: \(error)")
            }
        }
    }
    
    func testNetworkError() async throws {
        let networkError = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network connection failed"])
        let session = createMockSession(data: nil, response: nil, error: networkError)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .networkError = error {
                // Expected
            } else {
                XCTFail("Expected networkError, got: \(error)")
            }
        }
    }
    
    func testServerError() async throws {
        let response = createHTTPResponse(statusCode: 500)
        let session = createMockSession(data: Data(), response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .serverError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected serverError, got: \(error)")
            }
        }
    }
    
    func testRateLimitExceeded() async throws {
        let response = createHTTPResponse(statusCode: 403)
        let session = createMockSession(data: Data(), response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .rateLimitExceeded = error {
                // Expected
            } else {
                XCTFail("Expected rateLimitExceeded, got: \(error)")
            }
        }
    }
    
    func testCustomErrorFromGitHub() async throws {
        let errorResponse = MockHTTPClient.createMockErrorResponse(message: "Not Found")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let errorData = try encoder.encode(errorResponse)
        
        let response = createHTTPResponse(statusCode: 404)
        let session = createMockSession(data: errorData, response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "nonexistent")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .customError(let message) = error {
                XCTAssertEqual(message, "Not Found")
            } else {
                XCTFail("Expected customError, got: \(error)")
            }
        }
    }
    
    func testNoData() async throws {
        let response = createHTTPResponse(statusCode: 200)
        let session = createMockSession(data: Data(), response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .noData = error {
                // Expected
            } else {
                XCTFail("Expected noData, got: \(error)")
            }
        }
    }
    
    func testDecodingError() async throws {
        let invalidData = "invalid json".data(using: .utf8)!
        let response = createHTTPResponse(statusCode: 200)
        let session = createMockSession(data: invalidData, response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Expected decodingError, got: \(error)")
            }
        }
    }
    
    func testCancellation() async throws {
        let session = createMockSession(data: nil, response: nil, error: URLError(.cancelled))
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .networkError = error {
                // Expected - URLError(.cancelled) is treated as a network error
            } else {
                XCTFail("Expected networkError, got: \(error)")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testRequestWithBody() async throws {
        let mockUser = MockHTTPClient.createMockUser()
        let userData = try JSONEncoder().encode(mockUser)
        
        let response = createHTTPResponse(statusCode: 200)
        let session = createMockSession(data: userData, response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = TestEndpoint(
            baseUrl: URL(string: "https://api.github.com")!,
            path: "/test",
            method: .post,
            header: ["Content-Type": "application/json"],
            body: mockUser,
            query: nil
        )
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.login, "testuser")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testRequestWithQuery() async throws {
        let mockSearchResponse = MockHTTPClient.createMockSearchResponse(
            totalCount: 1,
            users: [MockHTTPClient.createMockUser()]
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let responseData = try encoder.encode(mockSearchResponse)
        
        let response = createHTTPResponse(statusCode: 200)
        let session = createMockSession(data: responseData, response: response, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.searchUsers(query: "testuser", page: 1, perPage: 10)
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: SearchResponse<GitHubUser>.self)
        
        switch result {
        case .success(let searchResponse):
            XCTAssertEqual(searchResponse.totalCount, 1)
            XCTAssertEqual(searchResponse.items.count, 1)
            XCTAssertEqual(searchResponse.items.first?.login, "testuser")
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testInvalidResponseType() async throws {
        let mockUser = MockHTTPClient.createMockUser()
        let userData = try JSONEncoder().encode(mockUser)
        
        // Create a mock response that's not HTTPURLResponse
        let session = createMockSession(data: userData, response: nil, error: nil)
        
        let httpClient = HTTPClientImpl(session: session)
        let endpoint = AppEndpoints.getUserDetails(username: "testuser")
        
        let result = await httpClient.sendRequest(endpoint: endpoint, responseModel: GitHubUser.self)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            if case .networkError = error {
                // Expected
            } else {
                XCTFail("Expected networkError, got: \(error)")
            }
        }
    }
}

// MARK: - Test Helpers

private struct TestEndpoint: Endpoint {
    let baseUrl: URL
    let path: String
    let method: RequestMethod
    let header: [String: String]?
    let body: (any Codable)?
    let query: [String: Any]?
    let mimeType: String?
    let fileName: String?
    
    init(baseUrl: URL, path: String, method: RequestMethod, header: [String: String]?, body: (any Codable)?, query: [String: Any]?) {
        self.baseUrl = baseUrl
        self.path = path
        self.method = method
        self.header = header
        self.body = body
        self.query = query
        self.mimeType = nil
        self.fileName = nil
    }
}

// MARK: - Mock URL Protocol

private class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    private static let lock = NSLock()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        MockURLProtocol.lock.lock()
        defer { MockURLProtocol.lock.unlock() }
        
        guard let handler = MockURLProtocol.requestHandler else {
            let error = NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response provided"])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // No-op
    }
    
    // Reset the handler to ensure clean state
    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        requestHandler = nil
    }
    
    // Set handler with lock protection
    static func setHandler(_ handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)) {
        lock.lock()
        defer { lock.unlock() }
        requestHandler = handler
    }
} 