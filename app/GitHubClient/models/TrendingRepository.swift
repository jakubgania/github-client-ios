//
//  TrendingRepository.swift
//  GitHubClient
//
//  Created by Jakub on 14.06.25.
//

import Foundation

struct TrendingRepository: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String?
    let url: String?
    let description: String?
    let language: String?
    let languageColor: String?
    let stars: String?
    let forks: String?
    let buildBy: [BuildBy]?
    let starsToday: String?
    
    enum CodingKeys: String, CodingKey {
            case title, url, description, language
            case languageColor = "language_color"
            case stars, forks
            case buildBy = "build_by"
            case starsToday = "stars_today" // Map snake_case to camelCase
        }
}

struct BuildBy: Codable, Identifiable {
    var id: String { UUID().uuidString }
    let type: String?
    let avatarUrl: String?
}
