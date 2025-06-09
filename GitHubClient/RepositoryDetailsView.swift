//
//  RepositoryDetailsView.swift
//  GitHubClient
//
//  Created by Jakub on 08.06.25.
//

import SwiftUI

struct RepositoryDetailsView: View {
    @StateObject private var viewModel = GitHubViewModel()
    
    @State private var topicDetails = false
    @State private var selectedItem: String? = nil
    
    var repositoryName: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Avatar(urlString: viewModel.repositoryDetails?.owner.avatarUrl ?? "", size: 26, type: Avatar.AvatarType(from: viewModel.repositoryDetails?.owner.type))
                    
                    Text(viewModel.repositoryDetails?.owner.login ?? "")
                        .foregroundStyle(.gray)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                
                Text(viewModel.repositoryDetails?.name ?? "")
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                    .padding(.bottom, 8)
                
                Text(viewModel.repositoryDetails?.description ?? "No description")
                    .padding(.bottom, 8)
                
                if let homepage = viewModel.repositoryDetails?.homepage {
                    if let url = URL(string: homepage) {
                        let domain = extractDomain(from: url.absoluteString)
                        if let domain {
                            HStack {
                                Link(destination: url) {
                                    Image(systemName: "link")
                                        .font(.callout)
                                        .bold()
                                        .foregroundStyle(.gray)
                                    
                                    Text(domain)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.black)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    HStack {
                        Image(systemName: "star")
                            .font(.callout)
                            .bold()
                            .foregroundStyle(.gray)
                        
                        if let stargazersCount = viewModel.repositoryDetails?.stargazerCount {
                            if stargazersCount > 0 {
//                                stargzers view
                            } else {
                                Text("\(stargazersCount)")
                                    .fontWeight(.semibold)
                                
                                Text("stars")
                                    .foregroundStyle(.gray)
                                    .padding(.leading, -2)
                            }
                        }
                    }
                    .padding(.trailing, 14)
                    
                    HStack {
                        Image(systemName: "option")
                            .rotationEffect(.degrees(-90))
                            .bold()
                            .font(.callout)
                            .foregroundStyle(.gray)
                        
                        if let forksCount = viewModel.repositoryDetails?.forksCount {
                            if forksCount > 0 {
                                
                            } else {
                                Text("\(forksCount)")
                                    .fontWeight(.semibold)
                                
                                Text("forks")
                                    .foregroundStyle(.gray)
                                    .padding(.leading, -2)
                            }
                        }
                    }
                }
                
                HStack(spacing: 14) {
                    Button {
                        
                    } label: {
                        Image(systemName: "star")
                            .bold()
                        
                        Text("Star")
                            .foregroundStyle(.black)
                            .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray100)
                    .clipShape(.rect(cornerRadius: 8))
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "bell.fill")
                            .padding(10)
                    }
                    .background(Color.gray100)
                    .clipShape(.rect(cornerRadius: 8))
                }
                
                if let topics = viewModel.repositoryDetails?.topics, !topics.isEmpty {
                    Text("Topics:")
                        .padding(.bottom, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(topics, id: \.self) { item in
                                Button(item) {
                                    self.topicDetails = true
                                    self.selectedItem = item
                                }
                                .fontWeight(.medium)
                                .padding(8)
                                .foregroundStyle(.blue)
                                .background(Color.gray100)
                                .clipShape(.rect(cornerRadius: 8))
                                .font(.subheadline)
                                .sheet(isPresented: Binding( get: { topicDetails }, set: { topicDetails = $0 }), onDismiss: didDismiss) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(self.selectedItem ?? "no item")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                            
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .padding(.top, 12)
                                    .frame(maxWidth: .infinity)
                                    .presentationDetents([.medium, .large])
                                    .presentationContentInteraction(.resizes)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                VStack {
                    List {
                        if let issuesUrl = viewModel.repositoryDetails?.issuesUrl {
                            NavigationLink {
//                                issues view
                            } label: {
                                Text("Issues")
                                    .padding(.vertical, 10)
                            }
                            .listRowInsets(.init())
                            .listRowSeparator(.hidden)
                        }
                        
                        if (viewModel.repositoryDetails?.pullsUrl) != nil {
                            NavigationLink {
//                                pulls view
                            } label: {
                                Text("Pull Requests")
                                    .padding(.vertical, 10)
                            }
                            .listRowInsets(.init())
                            .listRowSeparator(.hidden)
                        }
                        
                        if let contributorsUrl = viewModel.repositoryDetails?.contributorsUrl {
                            NavigationLink {
//                                contributors view
                            } label:{
                                Text("Contributors")
                                    .padding(.vertical, 10)
                            }
                            .listRowInsets(.init())
                            .listRowSeparator(.hidden)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .ignoresSafeArea()
                    .frame(maxHeight: 120)
                }
                .padding(.bottom, 10)
                
                if let repositoryUrl = viewModel.repositoryDetails?.htmlUrl {
                    let url = URL(string: repositoryUrl)
                    
                    if let url {
                        Link(destination: url, label: {
                            Text("Visit Repository")
                                .foregroundStyle(.black)
                        })
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .task {
            await viewModel.fetchRepositoryDetails(repositoryId: repositoryName)
        }
    }
    
    func extractDomain(from urlString: String) -> String? {
        let fixedURLString = urlString.contains("://") ? urlString : "https://" + urlString
        
        guard let url = URL(string: fixedURLString), let host = url.host else {
            return nil
        }
        
        return host + url.path
    }
    
    func didDismiss() {
        self.topicDetails = false
    }
}

#Preview {
    RepositoryDetailsView(repositoryName: "jakubgania/angular8-omdbapi-movie-search-engine")
}
