//
//  Endpoint.swift
//  GitHubUsersApp
//
//  Created by Umair on 07/07/2025.
//

import Foundation

public protocol Endpoint {
    var baseUrl: URL { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var query: [String: Any]? { get }
    var body: Codable? { get }
    var mimeType: String? { get }
    var fileName: String? { get }
}

public enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}
