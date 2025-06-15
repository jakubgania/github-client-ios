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
                NavigationLink {
                    RepositoryDetailsView(repositoryName: repository.title?.replacingOccurrences(of: " ", with: "") ?? "")
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(repository.title ?? "")
                                .fontWeight(.medium)
                                .padding(.bottom, 4)
                                .lineLimit(1)
                            
                            Text(repository.description ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 4)
                            
                            HStack {
                                if let language = repository.language, !language.isEmpty {
                                    Image(systemName: "circle.fill")
                                        .font(.caption2)
                                        .foregroundStyle(Color(hex: repository.language ?? "#000000"))
                                }
                                
                                Image(systemName: "star")
                                Text(repository.stars ?? "")
                                    .padding(.leading, -4)
                                
                                Image(systemName: "option")
                                    .rotationEffect(.degrees(-90))
                                    .bold()
                                
                                Text(repository.forks ?? "")
                                    .padding(.leading, -4)
                            }
                            .font(.footnote)
                            .foregroundStyle(.black)
                            
                            HStack(spacing: 4) {
                                Text("Build by:")
                                    .foregroundStyle(.black)
                                    .font(.footnote)
                                    .padding(.trailing, 4)
                                
                                if let buildBy = repository.buildBy, !buildBy.isEmpty {
                                    ForEach(buildBy) { item in
                                        Avatar(urlString: item.avatarUrl ?? "", size: 18, type: Avatar.AvatarType(from: item.type))
                                    }
                                }
                                
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.black)
                    }
                    .padding()
                    .background(Color.gray50)
                    .cornerRadius(12)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal)
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
            buildBy: [
                BuildBy(type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/31396011?s=40&v=4"),
                BuildBy(type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/31396011?s=40&v=4"),
                BuildBy(type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/31396011?s=40&v=4"),
                BuildBy(type: "User", avatarUrl: "https://avatars.githubusercontent.com/u/31396011?s=40&v=4"),
            ],
            starsToday: "240"
        )
    ])
}
