//
//  NetworkError.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

/// Network-related errors
public enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case rateLimitExceeded
    case customError(String)
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .customError(let message):
            return message
        case .cancelled:
            return "Request was cancelled"
        }
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.cancelled, .cancelled):
            return true
        case let (.decodingError(lhsError), .decodingError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.networkError(lhsError), .networkError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.customError(lhsMessage), .customError(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
