//
//  TrendingRepositoriesView.swift
//  GitHubClient
//
//  Created by Jakub on 14.06.25.
//

import SwiftUI

struct TrendingRepositoriesView: View {
    let trendingRepositories: [TrendingRepository]
    
    var body: some View {
        ViewDescription(description: "See what the GitHub community is most excited about today.")
        
        if !trendingRepositories.isEmpty {
            ForEach(trendingRepositories) { repository in
                Text(repository.title ?? "")
            }
        }
    }
}

#Preview {
    TrendingRepositoriesView(trendingRepositories: [
        TrendingRepository(
            title: "awesome-ios",
            url: "https://github.com/vsouza/awesome-ios",
            description: "A curated list of awesome iOS frameworks and libraries.",
            language: "Swift",
            languageColor: "#F05138",
            stars: "95000",
            forks: "4500",
            buildBy: [],
            starsToday: "240"
        )
    ])
}
