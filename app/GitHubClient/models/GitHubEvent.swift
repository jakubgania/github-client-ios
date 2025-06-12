//
//  GitHubEvent.swift
//  GitHubClient
//
//  Created by Jakub on 01.06.25.
//

import Foundation

struct GitHubEvent: Codable, Identifiable {
    let id: String
    let type: String
    let actor: Actor
    let repo: Repo
    let payload: Payload
    let createdAt: String
}

struct Actor: Codable {
    let id: Int
    let login: String
    let avatarUrl: String
}

struct Repo: Codable, Identifiable {
    let id: Int
    let name: String
    let url: URL
}

struct Payload: Codable {
    let ref: String?
    let refType: String?
    let commits: [Commit]?
    let size: Int?
}

struct Commit: Codable {
    let sha: String
    let message: String
    let url: URL
    let author: CommitAuthor
}

struct CommitAuthor: Codable {
    let email: String
    let name: String
}
