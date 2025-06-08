//
//  RepositoryInfo.swift
//  GitHubClient
//
//  Created by Jakub on 08.06.25.
//

import Foundation

struct RepositoryInfo: Codable {
    let name: String?
    let owner: Owner
    let description: String?
    let htmlUrl: String?
    let homepage: String?
    let topics: [String]?
    let stargazerCount: Int?
    let stargazersUrl: String?
    let forksCount: Int?
    let forksUrl: String?
    let issuesUrl: String?
    let contributorsUrl: String?
    let pullsUrl: String?
}

struct Owner: Codable {
    let login: String?
    let avatarUrl: String?
    let type: String?
}
