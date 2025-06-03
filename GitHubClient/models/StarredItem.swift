//
//  StarredItem.swift
//  GitHubClient
//
//  Created by Jakub on 02.06.25.
//

import Foundation

struct StarredItem: Identifiable, Codable {
    let id: Int
    let name: String
    let owner: OwnerItem
    let htmlUrl: String
    let description: String?
    let stargazersCount: Int
    let langugage: String?
    let topics: [String]
}

struct OwnerItem: Codable {
    let login: String
    let avatarUrl: String
    let type: String
}
