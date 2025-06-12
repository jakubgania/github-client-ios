//
//  Follower.swift
//  GitHubClient
//
//  Created by Jakub on 02.06.25.
//

import Foundation

struct Follower: Identifiable, Codable {
    let id: Int
    let login: String?
    let avatarUrl: String?
    let htmlUrl: String?
    let type: String?
}
