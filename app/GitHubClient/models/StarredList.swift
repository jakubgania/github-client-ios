//
//  StarredList.swift
//  GitHubClient
//
//  Created by Jakub on 04.06.25.
//

import Foundation
import SwiftData

@Model
final class StarredList {
    @Attribute(.unique) var title: String
    var listDescription: String?
    
    @Relationship(inverse: \StarredRepository.starredList)
    var repositories: [StarredRepository] = []
    
    init(title: String, listDescription: String? = nil, repositories: [StarredRepository]) {
        self.title = title
        self.listDescription = listDescription
        self.repositories = repositories
    }
}

@Model
final class StarredRepository {
    @Attribute(.unique) var name: String?
    var repositoryDescription: String?
    var language: String?
    var stargazersCount: Int = 0
    
    @Relationship var starredList: StarredList?
//    @Relationship(inverse: \StarredList.repositories)
//    var starredList: StarredList?
    
    init(name: String?, repositoryDescription: String?, language: String?, stargazersCount: Int?, starredList: StarredList) {
        self.name = name
        self.repositoryDescription = repositoryDescription
        self.language = language
        self.stargazersCount = stargazersCount ?? 0
        self.starredList = starredList
    }
}
