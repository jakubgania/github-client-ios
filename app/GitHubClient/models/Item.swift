//
//  Item.swift
//  GitHubClient
//
//  Created by Jakub on 25.05.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    @Attribute(.unique) var login: String
    var name: String?
    var avatartUrl: String?
    var type: String?
    
    init(login: String, name: String, avatarUrl: String, type: String) {
        self.login = login
        self.name = name
        self.avatartUrl = avatarUrl
        self.type = type
    }
}
