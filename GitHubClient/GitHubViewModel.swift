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
    @Published var profile: Profile?
    @Published var errorMessage: String?
    
    private let service: GitHubService
    private var context: ModelContext?
    
    
    init(service: GitHubService = GitHubService()) {
        self.service = service
    }

   func setContext(_ context: ModelContext) {
       self.context = context
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
           
            print("item ", item.login)
           context.insert(item)
           try? context.save()
       } catch {
           errorMessage = error.localizedDescription
       }
    }
}
