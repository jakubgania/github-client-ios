//
//  ContentView.swift
//  GitHubClient
//
//  Created by Jakub on 25.05.25.
//

import SwiftUI
import SwiftData

enum ViewType: String {
    case search = "search"
    case treningRepositories = "treningRepositories"
    case treningDevelopers = "trendingDevelopers"
    case popularTopics = "popularTopics"
    case collections = "collections"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var tokenInput: String = ""
    @State private var isSaved: Bool = false
    @State private var errorMessage: String?
    
    @State private var userInput: String = ""
    @State private var showTokenSheet: Bool = false
    @State private var selectedViewType: ViewType = .search
    
    var viewTitle: String {
        switch selectedViewType {
        case .search:
            return "Search"
        case .treningRepositories:
            return "Trening Repositories"
        case .treningDevelopers:
            return "Trening Developers"
        case .popularTopics:
            return "Topics"
        case .collections:
            return "Collections"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack(alignment: .leading, spacing: 12) {
                    VStack {
                        VStack {
                            HStack {
                                TextField("Enter username", text: $userInput)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                
                                Button {
                                    
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 24))
                                }
                            }
                            .padding(6)
                            .padding(.leading, 6.0)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(viewTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
//                            clear data
                        } label: {
                            Label("Clear data", systemImage: "externaldrive.badge.minus")
                        }
                        
                        Button {
                            showTokenSheet = true
                        } label: {
                            Label("Set API token", systemImage: "arrow.forward")
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showTokenSheet) {
                VStack {
                    Text(KeychainManager.shared.getToken() ?? "No token saved")
//                    Text("\(token.prefix(4))••••\(token.suffix(4))")
                    
                    TextField("Enter GitHub Token", text: $tokenInput)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button(action: {
                        let success = KeychainManager.shared.saveToken(tokenInput)
                        if success {
                            isSaved = true
                            errorMessage = nil
                        } else {
                            errorMessage = "Failed to save token"
                        }
                    }) {
                        Text("Save token")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .alert("Success", isPresented: $isSaved) {
                        Button("OK") { }
                    } message: {
                        Text("Token saved successfully!")
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
