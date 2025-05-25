//
//  ViewDescription.swift
//  GitHubClient
//
//  Created by Jakub on 26.05.25.
//

import SwiftUI

struct ViewDescription: View {
    var description: String
    
    var body: some View {
        Text(description)
            .font(.body)
            .fontWeight(.medium)
            .padding(.vertical, 4)
            .foregroundStyle(.black)
            .padding(.horizontal)
    }
}

#Preview {
    ViewDescription(description: "This is a sample description for the preview.")
}
