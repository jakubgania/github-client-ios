//
//  GitHubService.swift
//  GitHubClient
//
//  Created by Jakub on 25.05.25.
//

import Foundation
import SwiftData

final class GitHubService {
    private let baseURL = "https://api.github.com"
    private let apiVersion = "2022-11-28"
    private let networkClient = NetworkClient()
    private let keychain = KeychainManager.shared

    private func makeRequest(path: String, method: String = "GET", requiresAuth: Bool = false, queryParams: [String: String]? = nil) throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL + path)
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")

        if requiresAuth {
            guard let token = keychain.getToken() else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    func fetchUserProfile(username: String) async throws -> Profile {
        let request = try makeRequest(path: "/users/\(username)", requiresAuth: true)
        return try await networkClient.fetch(request)
    }

//    func fetchTrendingRepositories() async throws -> [TrendingRepository] {
//        let request = try makeRequest(path: "/some/custom/trending-endpoint")
//        return try await networkClient.fetch(request)
//    }

//    func fetchTrendingDevelopers() async throws -> [TrendingDevelopers] {
//        let request = try makeRequest(path: "/some/custom/devs-endpoint")
//        return try await networkClient.fetch(request)
//    }
}
