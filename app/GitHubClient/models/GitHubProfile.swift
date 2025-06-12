//
//  GitHubProfile.swift
//  GitHubClient
//
//  Created by Jakub on 31.05.25.
//

import Foundation

struct GitHubProfile: Codable {
    let login: String?
    let name: String?
    let htmlUrl: String?
    let company: String?
    let avatarUrl: String?
    let bio: String?
    let blog: String?
    let twitterUsername: String?
    var socialAccounts: [SocialAccounts]?
    let type: String?
    let publicRepos: Int?
    let organizationsUrl: String?
    let followers: Int?
    let following: Int?
    let location: String?
    let starredUrl: String?
    let createdAt: String?
    let updatedAt: String?
    var events: [GitHubEvent]?
}

struct SocialAccounts: Codable, Identifiable {
    var id: String { url ?? UUID().uuidString }
    let provider: String?
    let url: String?
    
    var username: String? {
        guard let url else { return nil }
        
        if (provider?.lowercased()) != nil {
            return extractUsername(url: url)
        }
        
        return nil
    }
    
    private func extractUsername(url: String) -> String? {
        guard let url = URL(string: url) else { return nil }
        return url.lastPathComponent
    }
}
