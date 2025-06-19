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

extension Color {
    static let slate50 = Color(red: 248 / 255, green: 250 / 255, blue: 252 / 255)
    static let slate70 = Color(red: 244.5 / 255, green: 247.5 / 255, blue: 250.5 / 255)
    static let slate100 = Color(red: 241 / 255, green: 245 / 255, blue: 249 / 255)
    static let gray50 = Color(red: 249 / 255, green: 250 / 255, blue: 251 / 255)
    static let gray100  = Color(red: 243 / 255, green: 244 / 255, blue: 246 / 255)
}

struct Search: View {
    var items: [Item]
    
    var body: some View {
        ViewDescription(description: "Search users and organizations.")
        
        if items.isEmpty {
            VStack {
                Spacer()
                
                VStack {
                    HStack {
                        Text("What are you looking for...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.gray.opacity(0.4))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        
        ForEach(items.reversed()) { item in
            NavigationLink {
                ProfileView(username: item.login)
            } label: {
                HStack {
                    Avatar(urlString: item.avatartUrl, size: 50, type: Avatar.AvatarType(from: item.type))
                    
                    VStack(alignment: .leading) {
                        if let userName = item.name, !userName.isEmpty {
                            Text(userName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .lineLimit(2)
                        }
                        
                        Text(item.login)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray.secondary)
                    }
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.black)
                }
                .padding(10)
                .background(Color.gray50)
                .cornerRadius(12)
                .transition(.opacity)
            }
            .padding(.bottom, 2)
            .padding(.horizontal)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @StateObject private var viewModel = GitHubViewModel()
    
    @State private var tokenInput: String = ""
    @State private var isSaved: Bool = false
    @State private var errorMessage: String?
    
    @State private var userInput: String = ""
    @State private var showTokenSheet: Bool = false
    @State private var showUserSheet: Bool = false
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
    @State private var isSearchFieldActive = false // detect when search field is activated
    
    @FocusState private var isTextFieldActive: Bool
    @State private var suggestions = ["openai", "vercel", "apple", "microsoft", "google", "tensorflow", "aws", "ibm", "github", "facebookresearch"]
    
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
                                    resetScrollView()
                                    selectedViewType = .search
                                    selectedButton = 0
                                    
                                    Task {
                                        await viewModel.searchUser(username: userInput)
                                    }
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 24))
                                }
                            }
                            .padding(6)
                            .padding(.leading, 6.0)
                            .background(Color.gray50)
                            .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                    
                    if !isTextFieldActive {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal) {
                                HStack {
                                    Button {
                                        selectedViewType = .search
                                        selectedButton = 0
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
                                    .background(selectedButton == 0 ? Color.gray100 : Color.gray50)
                                    .clipShape(.rect(cornerRadius: 12))
                                    .id(0)
                                    
                                    Button {
                                        selectedViewType = .trendingRepositories
                                        selectedButton = 1
                                        
                                        Task {
                                            await viewModel.fetchTrendingRepositories()
                                        }
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
                                    .background(selectedButton == 1 ? Color.gray100 : Color.gray50)
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
                                    .background(selectedButton == 2 ? Color.gray100 : Color.gray50)
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
                                    .background(selectedButton == 3 ? Color.gray100 : Color.gray50)
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
                                    .background(selectedButton == 4 ? Color.gray100 : Color.gray50)
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
                                    .background(selectedButton == 4 ? Color.gray100 : Color.gray50)
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
                            Search(items: items)
                        case .trendingRepositories:
//                            TrendingRepositoriesView()
//                            TrendingRepositoriesView(viewModel: viewModel.trendingRepositories)
                            TrendingRepositoriesView(trendingRepositories: viewModel.trendingRepositories)
                        case .trendingDevelopers:
                            Text("view for trending developers")
                        case .popularTopics:
                            Text("view for popular topics")
                        case .collections:
                            Text("view for collections")
                        }
                    } else {
                        VStack(alignment: .leading) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                HStack {
                                    Text(suggestion)
                                        .padding(.leading, 12)
                                        .onTapGesture {
                                            Task {
                                                await viewModel.searchUser(username: suggestion)
                                            }
                                            userInput = suggestion
                                            isTextFieldActive.toggle()
                                        }
                                }
                                .frame(height: 38)
                            }
                        }
                        .padding()
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
                        
                        Button {
                            showUserSheet = true
                        } label: {
                            Label("User profile", systemImage: "person.fill")
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
            .sheet(isPresented: $showUserSheet) {
//              https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-the-authenticated-user
                VStack {
                    Text("User Details")
                    Text("\(viewModel.me?.login ?? "No user logged in")")
                }
            }
        }
        .task {
//          task because it is an asyncronous operation
            viewModel.setContext(modelContext)
            await viewModel.loadAuthenticatedUser()
        }
    }
    
    private func resetScrollView() {
        isTextFieldActive = false
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
