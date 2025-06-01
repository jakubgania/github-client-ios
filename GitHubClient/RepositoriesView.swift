//
//  RepositoriesView.swift
//  GitHubClient
//
//  Created by Jakub on 31.05.25.
//

import SwiftUI

struct RepositoriesView: View {
//    @State private var repositories: [Repository] = []
    @State private var searchText: String = ""
    
    @StateObject private var viewModel = GitHubViewModel()
    
    var username: String
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(searchText.isEmpty ? viewModel.listOfReposForUsername : viewModel.listOfReposForUsername.filter {
                        $0.name?.lowercased().contains(searchText.lowercased()) ?? false
                    }, id: \.name) { item in
                        NavigationLink {
                            Text("repo details view")
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(item.name ?? "")
                                    .fontWeight(.medium)
                                
                                if let fork = item.fork, fork == true {
                                    Text("Forked")
                                        .font(fork ? .caption : .footnote)
                                        .underline()
                                        .foregroundStyle(.gray)
                                }
                                
                                if let description = item.description {
                                    Text(description)
                                        .lineLimit(5)
                                        .truncationMode(.tail)
                                }
                                
                                HStack {
                                    Image(systemName: "star")
                                    Text("\(item.stargazersCount ?? 0)")
                                        .padding(.leading, -4)
                                    Text(item.language ?? "")
                                        .foregroundStyle(.blue.gradient)
                                        .padding(.leading, 8)
                                }
                            }
                            .padding(.top, 6)
                            .padding(.bottom, 6)
                        }
                    }
                }
                .autocorrectionDisabled()
                .searchable(text: $searchText, placement: .automatic)
                .textInputAutocapitalization(.never)
                .listStyle(.inset)
                .font(.callout)
                .task {
                    await viewModel.fetchReposForUsername(username: username)
                }
            }
            .navigationTitle("Repositories")
            .navigationBarTitleDisplayMode(.automatic)
        }
//        .task {
//            await viewModel.fetchReposForUsername(username: username)
//        }
    }
}

#Preview {
    RepositoriesView(username: "jakubgania")
}
