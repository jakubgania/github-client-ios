//
//  StarredView.swift
//  GitHubClient
//
//  Created by Jakub on 03.06.25.
//

import SwiftUI
import SwiftData

struct StarredView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel = GitHubViewModel()
    
    @Query var starredLists: [StarredList]
    
    @State private var searchText: String = ""
    @State private var showingCreateListSheet: Bool = false
    
    var username: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    if viewModel.me?.login == username {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundStyle(.black.opacity(0.6))
                                .font(.body)
                            
                            Text("My lists")
                                .font(.callout)
                                .foregroundStyle(.black.opacity(0.6))
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            if !starredLists.isEmpty {
                                Button("Create List") {
                                    showingCreateListSheet.toggle()
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        .listSectionSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.top, 30)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.06))
                        
                        if starredLists.isEmpty {
                            Section {
                                VStack {
                                    Text("Create your first list")
                                        .fontWeight(.semibold)
                                    
                                    Text("Lists make it easier to organize  and cute repositories you have starred.")
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color(UIColor.lightGray))
                                    
                                    Button {
                                        showingCreateListSheet.toggle()
                                    } label: {
                                        Text("Create a list")
                                            .foregroundStyle(.blue)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(.blue.opacity(0.2), lineWidth: 0.5)
                                            )
                                    }
                                    .background(Color.blue.opacity(0.05))
                                    .padding(.horizontal, 16)
                                }
                                .listRowInsets(EdgeInsets())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .listSectionSeparator(.hidden)
                        } else {
                            Section {
                                ForEach(starredLists, id: \.title) { starredList in
//                                    NavigationLink(destination: )
                                }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "star")
                                .foregroundStyle(.black.opacity(0.6))
                                .font(.body)
                            
                            Text("Starred")
                                .font(.callout)
                                .foregroundStyle(.black.opacity(0.6))
                                .padding(.leading, 8)
                            
                            Spacer()
                        }
                        .listSectionSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.06))
                    }
                }
                .autocorrectionDisabled()
                .searchable(text: $searchText, placement: .automatic)
                .textInputAutocapitalization(.never)
                .navigationTitle("Starred Repositories")
                .listStyle(PlainListStyle())
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
        .modelContainer(for: StarredList.self, inMemory: true)
}
