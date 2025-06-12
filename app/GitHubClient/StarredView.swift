//
//  StarredView.swift
//  GitHubClient
//
//  Created by Jakub on 03.06.25.
//

import SwiftUI
import SwiftData

enum ProgrammingLanguageColor: String {
    case javascript = "JavaScript"
    case python = "Python"
    case typescript = "TypeScript"
    case go = "Go"
    case csharp = "C#"
    case html = "HTML"
    case mako = "Mako"
    case php = "PHP"
    case vue = "Vue"
    case cplusplus = "C++"
    case rust = "Rust"
    case dart = "Dart"
    case dockerfile = "Dockerfile"
    case c = "C"
    case shell = "Shell"
    case bicep = "Bicep"
    case css = "CSS"
    case powershell = "PowerShell"
    
    var color: Color {
        switch self {
        case .javascript:
            return Color(hex: "#f1e05a")
        case .python:
            return Color(hex: "#3572A5")
        case .typescript:
            return Color(hex: "#3178c6")
        case .go:
            return Color(hex: "#00ADD8")
        case .csharp:
            return Color(hex: "#178600")
        case .html:
            return Color(hex: "#e34c26")
        case .mako:
            return Color(hex: "#7e858d")
        case .php:
            return Color(hex: "#4F5D95")
        case .vue:
            return Color(hex: "#41b883")
        case .cplusplus:
            return Color(hex: "#f34b7d")
        case .rust:
            return Color(hex: "#dea584")
        case .dart:
            return Color(hex: "#00B4AB")
        case .dockerfile:
            return Color(hex: "#384d54")
        case .c:
            return Color(hex: "#555555")
        case .shell:
            return Color(hex: "#89e051")
        case .bicep:
            return Color(hex: "#519aba")
        case .css:
            return Color(hex: "#563d7c")
        case .powershell:
            return Color(hex: "#012456")
        }
    }
    
    init?(language: String) {
        self.init(rawValue: language)
    }
}

struct StarredView: View {
    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = GitHubViewModel()
    
    @Query var starredLists: [StarredList]
    
    @State private var searchText: String = ""
    @State private var listName: String = ""
    @State private var listDescription: String = ""
    @State private var showingCreateListSheet: Bool = false
    @State private var showingSelectListSheet: Bool = false
    @State private var isAlertShown = false
    @State private var isAlertShownDeleteList = false
    @State private var selectedRepository: StarredItem?
    
    var username: String = ""
    
    var listHeight: CGFloat {
        return CGFloat(128 + (starredLists.count > 0 ? starredLists.count * 42 : 0))
    }
    
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
                                   NavigationLink(destination: StarredListDetailsView(listTitle: starredList.title)) {
                                        HStack {
                                            Text("\(starredList.title)")
                                            
                                            Spacer()
                                            
                                            Text("\(starredList.repositories.count)")
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteItems)
                                .listStyle(.plain)
                            }
                            .listSectionSeparator(.hidden)
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
                    
                    Section {
                        ForEach(searchText.isEmpty ? viewModel.starredRepositories : viewModel.starredRepositories.filter {
                            $0.topics.contains(searchText.lowercased()) ||
                            $0.name.lowercased().contains(searchText.lowercased())
                        }, id: \.name) { item in
                            VStack(alignment: .leading) {
                                HStack(spacing: 12) {
                                    Avatar(urlString: item.owner.avatarUrl, size: 24, type: Avatar.AvatarType(from: item.owner.type))
                                    
                                    Text(item.owner.login)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    if viewModel.me?.login == username {
                                        Button {
                                            self.showingSelectListSheet.toggle()
                                            self.selectedRepository = item
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundStyle(Color(UIColor.lightGray))
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .padding(.top, 1)
                                        .padding(.bottom, 3)
                                    
                                    if let description = item.description, !description.isEmpty {
                                        Text(description)
                                            .lineLimit(5)
                                            .font(.callout)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    Label {
                                        Text("\(item.stargazersCount)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .padding(.leading, -18)
                                    } icon: {
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.yellow)
                                    }
                                    .padding(.leading, -6)
                                    
                                    if let language = item.language, !language.isEmpty {
                                        if let programmingLanguage = ProgrammingLanguageColor(language: language) {
                                            Label {
                                                Text(language)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                                    .padding(.leading, -18)
                                            } icon: {
                                                Image(systemName: "circle.fill")
                                                    .font(.caption2)
                                                    .foregroundStyle(programmingLanguage.color)
                                            }
                                            .padding(.leading, -6)
                                        }
                                    }
                                }
                                .padding(.vertical, 0.4)
                                
                                let listTitles = checkIfRepoIsAlreadyOnLists(repositoryName: item.name, lists: self.starredLists)
                                if !listTitles.isEmpty {
                                    HStack {
                                        Image(systemName: "list.bullet")
                                        
                                        if listTitles.count == 1 {
                                            Text(listTitles[0])
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text("\(listTitles.last!) + \(listTitles.count - 1)")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .autocorrectionDisabled()
                .searchable(text: $searchText, placement: .automatic)
                .textInputAutocapitalization(.never)
                .navigationTitle("Starred Repositories")
                .listStyle(PlainListStyle())
            }
            .sheet(isPresented: $showingCreateListSheet) {
                NavigationStack {
                    VStack(alignment: .leading) {
                        Divider()
                        
                        VStack {
                            TextField("List name", text: $listName, axis: .vertical)
                                .font(.title3)
                                .fontWeight(.medium)
                                .textInputAutocapitalization(.never)
                            
                            TextField("Description", text: $listDescription, axis: .vertical)
                                .padding(.top, 8)
                                .fontDesign(.monospaced)
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .navigationTitle("Create List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                print("cancel button")
                                if !self.listName.isEmpty || !self.listDescription.isEmpty {
                                    self.isAlertShown = true
                                } else {
                                    self.showingCreateListSheet = false
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Create") {
                                createStarredList()
                                self.showingCreateListSheet.toggle()
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(listName.isEmpty ? Color(UIColor.lightGray) : .accentColor)
                        }
                    }
                    .alert("Unsaved Changes", isPresented: $isAlertShown) {
                        Button(role: .destructive) {
//                            handle the deletion
                            self.showingCreateListSheet = false
                            self.listName = ""
                            self.listDescription = ""
                        } label: {
                            Text("Discard")
                        }
                    } message: {
                        Text("Are you sure you want to discard this new list? Your message will be lost.")
                    }
                }
            }
            .sheet(isPresented: $showingSelectListSheet, onDismiss: didDismissSelectedLists) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            
                            Button("Done") {
                                self.showingSelectListSheet = false
                            }
                            .fontWeight(.semibold)
                        }
                        .frame(maxHeight: 52)
                        .padding(.horizontal, 20)
                        .overlay(
                            Text("Select lists")
                                .fontWeight(.medium),
                            alignment: .center
                        )
                        .background(.white)
                        
                        Divider()
                        
                        List {
                            if !starredLists.isEmpty {
                                ForEach(starredLists, id: \.title) { starredList in
                                    Button {
                                        print(starredList.title)
                                        addRepoToSelectedList(listTitle: starredList.title)
                                    } label: {
                                        HStack {
                                            Text("\(starredList.title)")
                                            
                                            Spacer()
                                            
                                            if checkIfRepositoryIsAlreadyInList(starredList: starredList) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                        .padding(0)
                                    }
                                }
                            }
                            
                            Section {
                                HStack {
                                    Button {
                                        self.showingCreateListSheet.toggle()
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus")
                                            Text("Create list")
                                        }
                                        .ignoresSafeArea(.all)
                                        .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .listSectionSeparator(.hidden)
//                                .padding(.bottom, 6)
                        }
                        .listStyle(.inset)
                        .background(Material.bar)
//                            .padding(.top, -4)
                        .scrollContentBackground(.hidden)
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            .alert("Delete list?", isPresented: $isAlertShownDeleteList) {
                Button(role: .destructive) {
                    
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text("The 1 repositories in this list will remain starred.")
            }
        }
        .task {
            await viewModel.loadAuthenticatedUser()
            await viewModel.fetchStarredRepositories(username: username)
        }
    }
    
    func createStarredList() {
        print("create starred list")
        print("list name", self.listName)
        print("list description ", self.listDescription)
        
        do {
            let newList = StarredList(title: self.listName, listDescription: self.listDescription, repositories: [])
            
            self.modelContext.insert(newList)
            print(newList.id)
            try self.modelContext.save()
            print(newList.id)
            
            self.listName = ""
            self.listDescription = ""
        } catch {
            print("Failed to save the list: \(error)")
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        print("delete items")
        print("offsets ", offsets)
        
        for index in offsets {
            let itemToDelete = starredLists[index]
            self.modelContext.delete(itemToDelete)
        }
        
        try? self.modelContext.save()
    }
    
    func didDismissSelectedLists() {
        self.showingSelectListSheet = false
    }
    
    func addRepoToSelectedList(listTitle: String) {
        if let index = self.starredLists.firstIndex (where: { $0.title == listTitle }) {
            self.starredLists[index].repositories.append(
                StarredRepository(
                    name: self.selectedRepository?.name ?? "",
                    repositoryDescription: self.selectedRepository?.description ?? "",
                    language: self.selectedRepository?.language,
                    stargazersCount: self.selectedRepository?.stargazersCount ?? 0,
                    starredList: self.starredLists[index]
                )
            )
            
            try? self.modelContext.save()
        }
    }
    
    func checkIfRepositoryIsAlreadyInList(starredList: StarredList) -> Bool {
        return starredList.repositories.contains { $0.name == self.selectedRepository?.name }
    }
    
    func checkIfRepoIsAlreadyOnLists(repositoryName: String, lists: [StarredList]) -> [String] {
        var matchingLists: [String] = []
        
        for list in lists {
            if list.repositories.contains(where: { $0.name == repositoryName }) {
                matchingLists.append(list.title)
            }
        }
        
        return matchingLists
    }
}

#Preview {
    StarredView(username: "jakubgania")
        .modelContainer(for: StarredList.self, inMemory: true)
}
