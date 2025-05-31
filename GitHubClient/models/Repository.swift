//
//  Repository.swift
//  GitHubClient
//
//  Created by Jakub on 31.05.25.
//

import Foundation

struct Repository: Codable {
    let name: String?
    let description: String?
    let fork: Bool?
    let language: String?
    let stargazersCount: Int?
}
