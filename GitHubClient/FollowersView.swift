//
//  FollowersView.swift
//  GitHubClient
//
//  Created by Jakub on 02.06.25.
//

import SwiftUI

struct FollowersView: View {
    @StateObject private var viewModel = GitHubViewModel()
    
    var username: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.followers.indices, id: \.self) { idx in let follower = viewModel.followers[idx]
                    NavigationLink {
                        ProfileView(username: follower.login ?? "")
                    } label: {
                        HStack(spacing: 22) {
                            Avatar(urlString: follower.avatarUrl ?? "", size: 40, type: Avatar.AvatarType(from: follower.type))
                            
                            if let login = follower.login {
                                Text(login)
                                    .fontWeight(.semibold)
                            }
                    
                        }
                    }
                    .onAppear {
                        let prefetchDistance = 10
                        if idx == viewModel.followers.count - prefetchDistance {
                            Task {
                                await viewModel.fetchNextFollowersPage(for: username)
                            }
                        }
                    }
                }
                
                if viewModel.isFetchingFollowers {
                    HStack {
                        Spacer()
                        ProfileView()
                        Spacer()
                    }
                }
            }
            .listStyle(.inset)
        }
        .task {                       // first load
            await viewModel.resetFollowers(for: username)
        }
        .refreshable {                // swipe to refresh
            await viewModel.resetFollowers(for: username)
        }
    }
}

#Preview {
    FollowersView(username: "jakubgania")
}
