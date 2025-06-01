//
//  OrganizationsView.swift
//  GitHubClient
//
//  Created by Jakub on 01.06.25.
//

import SwiftUI

struct OrganizationsView: View {
    @StateObject private var viewModel = GitHubViewModel()
    
    var organizationsAPIEndpoint: String
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.organizations) { organization in
                        NavigationLink {
                            ProfileView(username: organization.login)
                        } label: {
                            HStack(spacing: 22) {
                                Avatar(urlString: organization.avatarUrl, size: 40, type: .organization)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(organization.login)
                                        .fontWeight(.semibold)
                                    
                                    if !organization.description.isEmpty {
                                        Text(organization.description)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Organizations")
                .listStyle(.inset)
            }
        }
        .task {
            if let url = URL(string: organizationsAPIEndpoint) {
                let trimmedEndpoint = url.path
                await viewModel.fetchOrganizations(endpoint: trimmedEndpoint)
            }
        }
    }
}

#Preview {
    OrganizationsView(organizationsAPIEndpoint: "https://api.github.com/users/jakubgania/orgs")
}
