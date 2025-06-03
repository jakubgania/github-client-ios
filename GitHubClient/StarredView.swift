//
//  StarredView.swift
//  GitHubClient
//
//  Created by Jakub on 03.06.25.
//

import SwiftUI

struct StarredView: View {
    @StateObject private var viewModel = GitHubViewModel()
    
    var username: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("info")
                Text(viewModel.me?.login ?? "ee")
                Text(viewModel.profile?.login ?? "dd")
                List {
                    if viewModel.me?.login == username {
                        Text("text")
                    }
                }
            }
        }
        .task {
            await viewModel.loadAuthenticatedUser()
            await viewModel.fetchStarredRepositories(username: username)
        }
    }
}

#Preview {
    StarredView(username: "jakubgania")
}
