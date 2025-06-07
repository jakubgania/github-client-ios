//
//  StarredListDetailsView.swift
//  GitHubClient
//
//  Created by Jakub on 05.06.25.
//

import SwiftUI
import SwiftData

struct StarredListDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var starredLists: [StarredList]
    
    init(listTitle: String) {
        self.listTitle = listTitle
        _starredLists = Query(filter: #Predicate { $0.title == listTitle })
    }
    
    var listTitle: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bookmark")
                    
                    if starredLists.count == 1 {
                        Text("1 repository")
                    } else {
                        Text("\(starredLists.count) repositories")
                    }
                }
                .foregroundStyle(.gray)
                
                if let list = starredLists.first {
                    List(list.repositories) { repository in
                        Text(repository.name ?? "Unknown Repository")
                    }
                    .listStyle(.inset)
                    .ignoresSafeArea(.all)
                    .background(.green)
                }
                
                Spacer()
                
                VStack(spacing: 14) {
                    Text("Add repositories to this list")
                        .fontWeight(.semibold)
                    
                    Text("Star repositories on GitHub to keep track of your favorite projects and inspirational code.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(UIColor.lightGray))
                    
//                    explr  view
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                
                Spacer()
            }
            .navigationTitle(listTitle)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    StarredListDetailsView(listTitle: "Example")
}
