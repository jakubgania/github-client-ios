//
//  IssuesView.swift
//  GitHubClient
//
//  Created by Jakub on 11.06.25.
//

import SwiftUI

struct IssuesView: View {
    @StateObject private var viewModel = GitHubViewModel()
    
    var repositoryName: String
    
    @State private var buttonOpenState: Bool = true
    @State private var buttonClosedState: Bool = false
    @State private var buttonAllState: Bool = false
    
//    @State private var selectedState: IssueState = .open
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        buttonOpenState = true
                        buttonClosedState = false
                        buttonAllState = false
                        
//                        selectedState = .open
                        Task {
                            await viewModel.fetchRepositoryIssuesByState(repositoryId: repositoryName, state: .open)
                        }
                    } label: {
                        Text("Open")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(buttonOpenState ? .white : .black)
                    }
                    .background(buttonOpenState ? Color.black.opacity(0.8) : Color.gray.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 14))
                }
                .padding(.leading)
                .padding(.vertical, 10)
                
                List {
                    ForEach(viewModel.repositoryIssues) { issue in
                        NavigationLink {
//                            issue details
                        } label: {
                            HStack(alignment: .top) {
                                if issue.state == "open" {
                                    Image(systemName: "smallcircle.filled.circle")
                                        .foregroundStyle(.green)
                                }
                                
                                if issue.state == "closed" {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(.purple)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    VStack {
                                        HStack(alignment: .top) {
                                            Text(issue.title ?? "No title")
                                            
                                            Spacer()
                                            
                                            let daysSinceOpen = self.daysFromDateTimeString(issue.createdAt ?? "")
                                            
                                            Text(String(daysSinceOpen))
                                                .padding(.leading, 10)
                                                .padding(.trailing, 14)
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    
                                    if let comments = issue.comments, comments > 0 {
                                        HStack {
                                            HStack(spacing: 3) {
                                                Image(systemName: "bubble.left.and.bubble.right")
                                                    .font(.system(size: 8))
                                                
                                                Text("\(comments)")
                                                    .font(.system(size: 12))
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                        }
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(.rect(cornerRadius: 10))
                                    }
                                }
                                .padding(.leading, 10)
                            }
                        }
                    }
                }
                .navigationTitle("Issues")
                .navigationBarTitleDisplayMode(.automatic)
                .listStyle(.inset)
            }
        }
        .task {
            await viewModel.fetchRepositoryIssues(repositoryId: repositoryName)
        }
    }
    
    func daysFromDateTimeString(_ dateTimeString: String) -> String {
        // GitHub-style ISO8601 date (e.g., "2023-04-10T15:34:56Z")
        let formatter = ISO8601DateFormatter()
        
        guard let givenDate = formatter.date(from: dateTimeString) else {
            print("⚠️ Invalid date format: \(dateTimeString)")
            return "0"
        }

        let now = Date()
        let days = Calendar.current.dateComponents([.day], from: givenDate, to: now).day ?? 0

        switch days {
        case ..<1:
            return "0"
        case 1...31:
            return "\(days)d"
        case 32...365:
            return "\(days / 30)mo"
        default:
            return "\(days / 365)yrs"
        }
    }
}

#Preview {
    IssuesView(repositoryName: "vercel/ai-chatbot")
}
