//
//  PinnedRepository.swift
//  GitHubClient
//
//  Created by Jakub on 16.06.25.
//

import Foundation

struct PinnedRepository: Identifiable, Codable {
    var id: String { name } 
    let name: String
    let description: String?
    let url: String
    let stargazerCount: Int
    let owner: PinnedOwner
}

struct PinnedOwner: Codable {
    let login: String
    let avatarUrl: String
}
