//
//  Issue.swift
//  GitHubClient
//
//  Created by Jakub on 11.06.25.
//

import Foundation

struct Issue: Identifiable, Codable {
    let id: Int
    let title: String?
    let comments: Int?
    let state: String?
    let createdAt: String?
}
