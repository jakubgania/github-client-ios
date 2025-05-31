//
//  ProfileView.swift
//  GitHubClient
//
//  Created by Jakub on 31.05.25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ProfileView: View {
//    @State private var user: GitHubProfile?
//    @EnvironmentObject var viewModel: GitHubViewModel
    @StateObject private var viewModel = GitHubViewModel()
    @State private var showingQRCodeSheet: Bool = false
    
    var username: String = ""
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if let avatarUrl = viewModel.fullProfile?.avatarUrl,
                           let type = viewModel.fullProfile?.type {
                            Avatar(
                                urlString: avatarUrl,
                                size: 50,
                                type: Avatar.AvatarType(from: type)
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            if let userName = viewModel.fullProfile?.name, !userName.isEmpty {
                                Text(userName)
                                    .font(.title2)
                                    .bold()
                            }
                            
                            if let userLogin = viewModel.fullProfile?.login, !userLogin.isEmpty {
                                Text(userLogin)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.leading, 10)
                        .animation(Animation.linear(duration: 0.2), value: viewModel.fullProfile?.name)
                    }
                    .padding(.bottom, 20)
                    
                    if let userBio = viewModel.fullProfile?.bio, !userBio.isEmpty {
                        Text(userBio)
                            .padding(.bottom, 20)
                    }
                    
                    HStack(spacing: 16) {
                        if let userCompany = viewModel.fullProfile?.company, !userCompany.isEmpty {
                            Section {
                                Label {
                                    Text(userCompany)
                                        .foregroundStyle(.gray)
                                } icon: {
                                    Image(systemName: "building.2")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        
                        if let userLocation = viewModel.fullProfile?.location, !userLocation.isEmpty {
                            Section {
                                Label {
                                    Text(userLocation)
                                        .foregroundStyle(.gray)
                                } icon: {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    
                    if let userTwitterUsername = viewModel.fullProfile?.twitterUsername, !userTwitterUsername.isEmpty {
                        Section {
                            Label {
                                Text("@\(userTwitterUsername)")
                            } icon: {
                                Image("x")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.loadFullProfile(username: username)
            print("Loaded profile:", viewModel.fullProfile ?? "nil")
        }
    }
}

#Preview {
    ProfileView(username: "jakubgania")
}
