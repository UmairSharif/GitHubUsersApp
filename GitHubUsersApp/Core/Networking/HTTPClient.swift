//
//  HTTPClient.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation
import SwiftUI
import os.log

public protocol HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, NetworkError>
}

public class HTTPClientImpl: HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.githubusersapp.network", category: "HTTPClient")
    
    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async -> Result<T, NetworkError> {
        guard var urlComponents = URLComponents(url: endpoint.baseUrl, resolvingAgainstBaseURL: false) else {
            return .failure(.invalidURL)
        }
        
        urlComponents.path = endpoint.path
        
        urlComponents.queryItems = endpoint.query?.map({ (key: String, value: Any) in
            return URLQueryItem(name: key, value: String(describing: value))
        })
        
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        
        if let body = endpoint.body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                logger.error("Failed to encode request body: \(error.localizedDescription)")
                return .failure(.networkError(error))
            }
        }
        
        let requestId = UUID().uuidString.prefix(8)
        logger.info("[\(requestId)] Starting request to: \(url.absoluteString)")
        logger.info("[\(requestId)] Method: \(endpoint.method.rawValue)")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            var safeHeaders = headers
            if let authHeader = safeHeaders["Authorization"] {
                safeHeaders["Authorization"] = "token [REDACTED]"
            }
            logger.info("[\(requestId)] Headers: \(safeHeaders)")
        }
        
        let startTime = Date()
        
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            
            // Check if task was cancelled after the request
            guard !Task.isCancelled else {
                logger.info("[\(requestId)] Request was cancelled after completion")
                return .failure(.cancelled)
            }
            
            let duration = Date().timeIntervalSince(startTime)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("[\(requestId)] Invalid response type")
                return .failure(.networkError(NSError(domain: "HTTPClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])))
            }
            
            logger.info("[\(requestId)] Response received in \(String(format: "%.2f", duration))s")
            logger.info("[\(requestId)] Status code: \(httpResponse.statusCode)")
            
            // Check rate limit headers
            if let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
               let limit = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Limit") {
                logger.info("[\(requestId)] Rate limit: \(remaining)/\(limit) requests remaining")
            }
            
            // Handle rate limiting
            if httpResponse.statusCode == 403 {
                logger.warning("[\(requestId)] Rate limit exceeded")
                return .failure(.rateLimitExceeded)
            }
            
            // Handle server errors
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("[\(requestId)] Server error: \(httpResponse.statusCode)")
                
                // Try to decode error response
                if let errorResponse = try? decoder.decode(GitHubErrorResponse.self, from: data) {
                    logger.error("[\(requestId)] GitHub error message: \(errorResponse.message)")
                    return .failure(.customError(errorResponse.message))
                }
                
                return .failure(.serverError(httpResponse.statusCode))
            }
            
            // Handle empty data
            guard !data.isEmpty else {
                logger.warning("[\(requestId)] Empty response data")
                return .failure(.noData)
            }
            
            // Log response data (truncated for large responses)
            let responseString = String(data: data, encoding: .utf8) ?? "unreadable"
            if responseString.count > 1000 {
                logger.info("[\(requestId)] Response data (truncated): \(String(responseString.prefix(1000)))...")
            } else {
                logger.info("[\(requestId)] Response data: \(responseString)")
            }
            
            do {
                let decodedResponse = try decoder.decode(responseModel, from: data)
                logger.info("[\(requestId)] Successfully decoded response of type: \(responseModel)")
                return .success(decodedResponse)
            } catch {
                logger.error("[\(requestId)] Decoding error: \(error.localizedDescription)")
                logger.error("[\(requestId)] Failed to decode type: \(responseModel)")
                return .failure(.decodingError(error))
            }
            
        } catch {
            // Check if the error is due to cancellation
            if error is CancellationError {
                logger.info("[\(requestId)] Request was cancelled")
                return .failure(.cancelled)
            }
            
            logger.error("[\(requestId)] Network error: \(error.localizedDescription)")
            return .failure(.networkError(error))
        }
    }
}
