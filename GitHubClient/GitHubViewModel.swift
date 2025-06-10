//
//  GitHubViewModel.swift
//  GitHubClient
//
//  Created by Jakub on 25.05.25.
//

import Foundation
import SwiftUI
import SwiftData

struct Profile: Decodable {
    let login: String?
    let name: String?
    let avatarUrl: String?
    let type: String?
}

@MainActor
final class GitHubViewModel: ObservableObject {
    @Published var me: AuthenticatedUser?
    @Published var profile: Profile?
    @Published var fullProfile: GitHubProfile?
    @Published var listOfReposForUsername: [Repository] = []
    @Published var socialAccounts: [SocialAccounts] = []
    @Published var organizations: [Organization] = []
    @Published var followers: [Follower] = []
    @Published var starredRepositories: [StarredItem] = []
    @Published var repositoryDetails: RepositoryInfo?
    @Published var repositoryIssues: [Issue] = []
    @Published var errorMessage: String?
    
    @Published var isFetchingFollowers = false
    private var followerPage = 1
    private let followerPerPage = 30
    private var reachedEndOfFollowers = false
    
    private let service: GitHubService
    private var context: ModelContext?
    
    
    init(service: GitHubService = GitHubService()) {
        self.service = service
    }

    func setContext(_ context: ModelContext) {
       self.context = context
    }
    
    func loadAuthenticatedUser() async {
        async let user = try await service.fetchAuthenticatedUser()
        
        do {
            self.me = try await user
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func searchUser(username: String) async {
        guard let context else {
            errorMessage = "Brak contextu"
            return
        }
        do {
           let profile = try await service.fetchUserProfile(username: username)
           self.profile = profile
           
           let item = Item(
               login: profile.login ?? "",
               name: profile.name ?? "",
               avatarUrl: profile.avatarUrl ?? "",
               type: profile.type ?? ""
           )
           
           context.insert(item)
           try? context.save()
       } catch {
           errorMessage = error.localizedDescription
       }
    }
    
    func loadFullProfile(username: String) async {        
        do {
            async let profile = service.getFullProfile(username: username)
            async let socialAccounts = service.getSocialAccounts(username: username)
            async let events = service.getEvents(username: username)
            
            var fullProfile = try await profile
            let fetchedSocialAccounts = try await socialAccounts
            let fetchedEvents = try await events
            
            fullProfile.socialAccounts = fetchedSocialAccounts
            fullProfile.events = fetchedEvents
            
            self.fullProfile = fullProfile
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchReposForUsername(username: String) async {
        async let repos = service.getReposForUsername(username: username)
        
        do {
            self.listOfReposForUsername = try await repos
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchOrganizations(endpoint: String) async {
        async let organizations = service.getOrganizations(organizationsAPIEndpoint: endpoint)
        
        do {
            self.organizations = try await organizations
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchFollowers(username: String, page: Int, perPage: Int) async {
        async let followers = service.getFollowers(username: username, page: page, perPage: perPage)
        
        do {
            self.followers = try await followers
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func resetFollowers(for username: String) async {
        followerPage = 1
        reachedEndOfFollowers = false
        followers.removeAll()
        await fetchNextFollowersPage(for: username)
    }

    func fetchNextFollowersPage(for username: String) async {
        guard !isFetchingFollowers, !reachedEndOfFollowers else { return }
        isFetchingFollowers = true
        defer { isFetchingFollowers = false }

        do {
            let newFollowers = try await service.getFollowers(
                username: username,
                page: followerPage,
                perPage: followerPerPage
            )

            if newFollowers.count < followerPerPage {
                reachedEndOfFollowers = true
            }
            followers.append(contentsOf: newFollowers)
            followerPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchStarredRepositories(username: String) async {
        async let starredRepos = service.getStarredRepositories(username: username)
        
        do {
            self.starredRepositories = try await starredRepos
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchRepositoryDetails(repositoryId: String) async {
        async let repositoryDetails = service.getRepositoryDetailsView(repositoryId: repositoryId)
        
        do {
            self.repositoryDetails = try await repositoryDetails
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchRepositoryIssues(repositoryId: String) async {
        async let repositoryIssues = service.getRepositoryIssues(repositoryId: repositoryId)
        
        do {
            self.repositoryIssues = try await repositoryIssues
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchRepositoryIssuesOpen(repositoryId: String) async {
        async let repositoryIssuesOpen = service.getRepositoryIssuesOpen(repositoryId: repositoryId)
        
        do {
            self.repositoryIssues = try await repositoryIssuesOpen
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
