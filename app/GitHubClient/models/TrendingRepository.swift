//
//  TrendingRepository.swift
//  GitHubClient
//
//  Created by Jakub on 14.06.25.
//

import Foundation

struct TrendingRepository: Codable, Identifiable {
    var id: String { url ?? UUID().uuidString}
    let title: String?
    let url: String?
    let description: String?
    let language: String?
    let languageColor: String?
    let stars: String?
    let forks: String?
    let buildBy: [BuildBy]?
    let starsToday: String?
}

struct BuildBy: Codable, Identifiable {
    var id: String { avatarUrl ?? UUID().uuidString }
    let type: String?
    let avatarUrl: String?
}
