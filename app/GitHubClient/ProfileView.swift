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
    
    private let itemWidthRatio: CGFloat = 0.8
    private let itemHeight: CGFloat = 240
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if let avatarUrl = viewModel.fullProfile?.avatarUrl,
                           let type = viewModel.fullProfile?.type {
                            Avatar(
                                urlString: avatarUrl,
                                size: 68,
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
                    
                    if let userBlog = viewModel.fullProfile?.blog, !userBlog.isEmpty {
                        Section {
                            Label {
                                if let url = URL(string: checkURL(blogURL: userBlog)) {
                                    Link(userBlog, destination: url)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                            } icon: {
                                Image(systemName: "link")
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    
                    if let socialAccounts = viewModel.fullProfile?.socialAccounts, !socialAccounts.isEmpty {
                        Text("social section")
                        ForEach(socialAccounts) { account in
                            Text(displayText(for: account))
                        }
                    }
                    
                    HStack {
                        Image(systemName: "person.2")
                            .font(.system(size: 14))
                        
                        Text("\(viewModel.fullProfile?.followers ?? 0)")
                            .bold()
                        
                        NavigationLink {
                            FollowersView(username: viewModel.fullProfile?.login ?? "")
                        } label: {
                            Text("followers")
                                .foregroundStyle(.gray)
                        }
                        
                        Text("•")
                        
                        Text("\(viewModel.fullProfile?.following ?? 0)")
                            .bold()
                        
                        Text("following")
                            .foregroundStyle(.gray)
                    }
                    
                    Button {
//                        follow
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Follow")
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 6))
                    
                    List {
                        NavigationLink {
                            RepositoriesView(username: viewModel.fullProfile?.login ?? "")
                        } label: {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(Color.teal)
                                    .clipShape(.rect(cornerRadius: 6))
                                Text("Repositories")
                                    .padding(.leading, 6)
                                Spacer()
                                Text("\(viewModel.fullProfile?.publicRepos ?? 0)")
                                    .foregroundStyle(.gray)
                            }
                            .frame(height: 40)
                        }
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                        
                        if viewModel.fullProfile?.type == "User" {
                            NavigationLink {
                                StarredView(username: viewModel.fullProfile?.login ?? "")
                            } label: {
                                HStack {
                                    Image(systemName: "star")
                                        .foregroundStyle(.white)
                                        .frame(width: 34, height: 34)
                                        .background(Color.orange)
                                        .clipShape(.rect(cornerRadius: 6))
                                    Text("Starred")
                                        .padding(.leading, 6)
                                    Spacer()
                                }
                            }
                            .listRowInsets(.init())
                            .listRowSeparator(.hidden)
                            
                            NavigationLink {
                                OrganizationsView(organizationsAPIEndpoint: viewModel.fullProfile?.organizationsUrl ?? "")
                            } label: {
                                HStack {
                                    Image(systemName: "building.2")
                                        .foregroundStyle(.white)
                                        .frame(width: 34, height: 34)
                                        .background(Color.accentColor)
                                        .cornerRadius(6)
                                    Text("Organizations")
                                        .padding(.leading, 6)
                                    Spacer()
                                }
                            }
                            .listRowInsets(.init())
                            .listRowSeparator(.hidden)
                        }
                    }
                    .scrollDisabled(true)
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .listRowSpacing(6)
                    .frame(minHeight: 140)
                    
                    if let pinned = viewModel.fullProfile?.pinnedRepositories, !pinned.isEmpty {
                        Text("Pinned")
                        
                        let screenWidth = UIScreen.main.bounds.width
                        let itemWidth = screenWidth * itemWidthRatio
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(pinned) { repository in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(alignment: .center, spacing: 6) {
                                            Avatar(
                                                urlString: repository.owner.avatarUrl,
                                                size: 22,
                                                type: Avatar.AvatarType(from: "user")
                                            )
                                            
                                            Text("\(repository.owner.login)")
                                                .font(.callout)
                                        }
                                        
                                        Text(repository.name)
                                        Text(repository.description ?? "")
                                            .font(.callout)
                                            .lineLimit(5)
                                        
                                        Spacer()
                                        
                                        HStack {
                                            Text("content")
                                        }
                                    }
                                    .padding()
                                    .frame(width: itemWidth, height: itemHeight, alignment: .topLeading)
                                    .background(Color.gray50)
                                    .clipShape(.rect(cornerRadius: 6))
                                }
                            }
                        }
                    }
                    
                    Button {
                        self.showingQRCodeSheet.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Share Profile")
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 6))
                    
                    Group {
                        HStack {
                            Text("Created at:")
                            Text(formattedDateTime(from: viewModel.fullProfile?.createdAt ?? "no data") ?? "Invalid date")
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            Text("Updated at:")
                            Text(formattedDateTime(from: viewModel.fullProfile?.updatedAt ?? "no data") ?? "Invalid date")
                        }
                    }
                    .font(.caption)
                    
                    ForEach(viewModel.fullProfile?.events ?? []) { event in
                        VStack(alignment: .leading) {
//                          https://docs.github.com/en/rest/using-the-rest-api/github-event-types?apiVersion=2022-11-28
                            Text(event.type)
                            Text(event.repo.name)
                            Text(event.actor.login)
                            if let commit = event.payload.commits?.first {
                                Text(commit.message)
                            } else {
                                Text("No commit message")
                            }
                            Text(daysAgo(from: event.createdAt, asString: true) as? String ?? "Unknown")
                        }
                    }
                }
                .padding()
                .task {
                    await viewModel.loadFullProfile(username: username)
                    print("Loaded profile:", viewModel.fullProfile ?? "nil")
                }
                .sheet(isPresented: $showingQRCodeSheet, onDismiss: didDismissQRCodeSheet) {
                    VStack {
                        Text("QR Code to profile")
                        
                        Image(uiImage: generateQRCode(from: viewModel.fullProfile?.htmlUrl ?? "https://github.com"))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                    }
                    .presentationDetents([.medium])
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func checkURL(blogURL: String) -> String {
        if blogURL.prefix(4) != "http" || blogURL.prefix(5) != "https" {
            return "https://\(blogURL)"
        } else {
            return blogURL
        }
    }
    
    private func displayText(for account: SocialAccounts) -> String {
        switch account.provider?.lowercased() {
        case "twitter", "instagram", "linkedin":
            return account.username ?? "No username"
        case "generic":
            return account.url ?? "No URL"
        default:
            return "Unknow provider"
        }
    }
    
    func didDismissQRCodeSheet() {
        self.showingQRCodeSheet = false
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func formattedDateTime(from dtString: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        if let date = formatter.date(from: dtString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            let formattedDate = dateFormatter.string(from: date)
            
            return formattedDate
        } else {
            return nil
        }
    }
    
    func daysAgo(from dtString: String, asString: Bool = false) -> Any {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        guard let date = formatter.date(from: dtString) else {
            print("Error: Invalid ISO 8601 date string: \(dtString)")
            return asString ? "Unknown" : 0
        }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        guard let days = components.day, days >= 0 else {
            return asString ? "In the future" : 0
        }
        
        if asString {
            switch days {
            case 0: return "Today"
            case 1: return "1 day ago"
            default: return "\(days) days ago"
            }
        }
        
        return days
    }
}

#Preview {
    ProfileView(username: "jakubgania")
}

#Preview("Profile view for org") {
    ProfileView(username: "microsoft")
}
