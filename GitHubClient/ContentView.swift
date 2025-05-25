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
    case trendingRepositories = "trendingRepositories"
    case trendingDevelopers = "trendingDevelopers"
    case popularTopics = "popularTopics"
    case collections = "collections"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
//    @StateObject private var viewModel = GitHubViewModel()
    
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
        case .trendingRepositories:
            return "Trening Repositories"
        case .trendingDevelopers:
            return "Trening Developers"
        case .popularTopics:
            return "Topics"
        case .collections:
            return "Collections"
        }
    }
    
    @State private var selectedButton: Int? = 0  // keep track of selected button if needed
    @State private var isSearchFieldActive = true // detect when search field is activated
    
    @FocusState private var isTextFieldActive: Bool

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
                                    .focused($isTextFieldActive)
                                
                                Button {
                                    Task {
//                                        await viewModel.searchUser(username: "jakubgania")
                                    }
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 24))
                                }
                            }
                            .padding(6)
                            .padding(.leading, 6.0)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    
                    if isTextFieldActive {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal) {
                                HStack {
                                    Button {
                                        selectedViewType = .search
                                    } label: {
                                        HStack {
                                            Text("✨")
                                            Text("Search")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                    }
                                    .background(selectedButton == 0 ? Color.gray.opacity(0.16) : Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .id(0)
                                    
                                    Button {
                                        selectedViewType = .trendingRepositories
                                        selectedButton = 1
                                    } label: {
                                        HStack {
                                            Text("🚀")
                                            Text("Trending Repositories")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                    }
                                    .background(selectedButton == 1 ? Color.gray.opacity(0.16) : Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .id(1)
                                    
                                    Button {
                                        selectedViewType = .trendingDevelopers
                                        selectedButton = 2
                                        
//                                        Task {
//                                            do {
//                                                try await getTrendingDevelopers()
//                                            }
//                                        }
                                    } label: {
                                        HStack {
                                            Text("👨‍💻")
                                            Text("Trending Developers")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                    }
                                    .background(selectedButton == 2 ? Color.gray.opacity(0.16) : Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .id(2)
                                    
                                    Button {
                                        selectedViewType = .popularTopics
                                        selectedButton = 3
                                        
//                                        Task {
//                                            do {
//                                                try await getTopicsData()
//                                            }
//                                        }
                                    } label: {
                                        HStack {
                                            Text("📡")
                                            Text("Topics")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                    }
                                    .background(selectedButton == 3 ? Color.gray.opacity(0.16) : Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12))
                                    //.hoverEffectDisabled(true)
                                    .id(3)
                                    
                                    Button {
                                        selectedViewType = .collections
                                        selectedButton = 4
                                        
//                                        Task {
//                                            do {
//                                                // try await getTopicsData()
//                                            }
//                                        }
                                    } label: {
                                        HStack {
                                            Text("📁")
                                            Text("Collections")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                    }
                                    .background(selectedButton == 4 ? Color.gray.opacity(0.16) : Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .id(4)
                                    
                                    Button {
                                        
                                    } label: {
                                        HStack {
                                            Text("🏢")
                                            Text("Organizations")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                    }
                                    .background(selectedButton == 4 ? Color.gray.opacity(0.16) : Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 12))
                                    .id(5)
                                }
                                .padding(.leading)
                                .padding(.trailing)
                                .id(-1)
                            }
                            .scrollIndicators(.hidden)
                            .onChange(of: isSearchFieldActive) {
                                if isSearchFieldActive {
                                    // scroll to the first item when search field is activated
                                    proxy.scrollTo(-1, anchor: .leading)
                                    // reset the state
                                    isSearchFieldActive = false
                                }
                            }
                        }
                        
                        switch selectedViewType {
                        case .search:
                            Text("view for search")
                        case .trendingRepositories:
                            Text("view for trending repositories")
                        case .trendingDevelopers:
                            Text("view for trending developers")
                        case .popularTopics:
                            Text("view for popular topics")
                        case .collections:
                            Text("view for collections")
                        }
                    }
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
        .onAppear {
//            viewModel.setContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
