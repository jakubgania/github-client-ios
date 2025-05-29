//
//  Avatar.swift
//  GitHubClient
//
//  Created by Jakub on 28.05.25.
//

import SwiftUI

struct Avatar: View {
    enum AvatarType {
        case user
        case organization

        init(from string: String?) {
            switch string?.lowercased() {
            case "user":
                self = .user
            default:
                self = .organization
            }
        }
    }
    
    let urlString: String?
    let size: CGFloat?
    let type: AvatarType
    
    var body: some View {
        CachedAsyncImage(url: URL(string: urlString!), transaction: .init(animation: .smooth)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                switch type {
                case .user:
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                case .organization:
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 6))
                }
            case .failure:
                switch type {
                case .user:
                    Circle()
                        .foregroundStyle(.gray.opacity(0.1))
                case .organization:
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.1))
                }
            @unknown default:
                Circle()
                    .foregroundStyle(.gray.opacity(0.1))
            }
        }
        .frame(width: size ?? 40, height: size ?? 40)
    }
}

#Preview {
    Avatar(urlString: "https://avatars.githubusercontent.com/u/21696393?v=4", size: 40, type: .user)
    Avatar(urlString: "https://avatars.githubusercontent.com/u/14985020?v=4", size: 40, type: .organization)
}
