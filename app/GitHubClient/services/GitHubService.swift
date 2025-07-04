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
    
    private let localServerURL = "http://192.168.178.30:8000"

    private func makeRequest(path: String,
                             method: String = "GET",
                             requiresAuth: Bool = false,
                             queryParams: [String: String]? = nil,
                             overrideBaseURL: String? = nil) throws -> URLRequest {
        
        let finalBaseURL = overrideBaseURL ?? baseURL
        var urlComponents = URLComponents(string: finalBaseURL + path)
        
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if !finalBaseURL.contains("github.com") {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if finalBaseURL.contains("github.com") {
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue(apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
        }

        if requiresAuth {
            guard let token = keychain.getToken() else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    func fetchAuthenticatedUser() async throws -> AuthenticatedUser {
        let request = try makeRequest(path: "/user", requiresAuth: true)
        return try await networkClient.fetch(request)
    }

    func fetchUserProfile(username: String) async throws -> Profile {
        let request = try makeRequest(path: "/users/\(username)", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getFullProfile(username: String) async throws -> GitHubProfile {
        let request = try makeRequest(path: "/users/\(username)", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getReposForUsername(username: String) async throws -> [Repository] {
        let request = try makeRequest(path: "/users/\(username)/repos?sort=created&direction=desc&per_page=100", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getSocialAccounts(username: String) async throws -> [SocialAccounts] {
        let request = try makeRequest(path: "/users/\(username)/social_accounts", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getEvents(username: String) async throws -> [GitHubEvent] {
        let request = try makeRequest(path: "/users/\(username)/events/public", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getOrganizations(organizationsAPIEndpoint: String) async throws -> [Organization] {
        let request = try makeRequest(path: organizationsAPIEndpoint, requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getFollowers(username: String, page: Int, perPage: Int) async throws -> [Follower] {
        let request = try makeRequest(path: "/users/\(username)/followers?page=\(page)&per_page=\(perPage)", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getStarredRepositories(username: String) async throws -> [StarredItem] {
        let request = try makeRequest(path: "/users/\(username)/starred", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getRepositoryDetailsView(repositoryId: String) async throws -> RepositoryInfo {
        print("repo details")
        print(repositoryId)
        let request = try makeRequest(path: "/repos/\(repositoryId)", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getRepositoryIssues(repositoryId: String) async throws -> [Issue] {
        let request = try makeRequest(path: "/repos/\(repositoryId)/issues", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getRepositoryIssuesOpen(repositoryId: String) async throws -> [Issue] {
        let request = try makeRequest(path: "/repos/\(repositoryId)/issues?state=open", requiresAuth: true)
        return try await networkClient.fetch(request)
    }
    
    func getRepositoryIssuesByState(repositoryId: String, state: IssueState? = nil) async throws -> [Issue] {
        var queryParams: [String: String]? = nil
        if let state = state {
            queryParams = ["state": state.rawValue]
        }
        let request = try makeRequest(path: "/repos/\(repositoryId)/issues", requiresAuth: true, queryParams: queryParams)
        return try await networkClient.fetch(request)
    }

    func getTrendingRepositories() async throws -> [TrendingRepository] {
        let request = try makeRequest(path: "/trending-repositories", requiresAuth: false, overrideBaseURL: localServerURL)
        return try await networkClient.fetch(request)
    }
    
//    func fetchTrendingDevelopers() async throws -> [TrendingDevelopers] {
//        let request = try makeRequest(path: "/some/custom/devs-endpoint")
//        return try await networkClient.fetch(request)
//    }
    
    func getPinnedRepositories(username: String) async throws -> [PinnedRepository] {
        let payload: [String:String] = [
            "token":  keychain.getToken() ?? "",
            "username": username
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        var request = try makeRequest(path: "/graphql/pinned-repos", method: "POST", requiresAuth: true, overrideBaseURL: localServerURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        return try await networkClient.fetch(request)
    }
}
