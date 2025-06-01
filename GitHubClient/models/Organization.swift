//
//  Organization.swift
//  GitHubClient
//
//  Created by Jakub on 01.06.25.
//

import Foundation

struct Organization: Identifiable, Codable {
    let login: String
    let id: Int
    let reposUrl: String
    let avatarUrl: String
    let description: String
}
