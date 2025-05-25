//
//  NetworkClient.swift
//  GitHubClient
//
//  Created by Jakub on 25.05.25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case noData
    case unauthorized
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP error: \(statusCode) - \(message ?? "Unknow error")"
        case .decodingError:
            return "Failed to decode response"
        case .noData:
            return "No data received from server"
        case .unauthorized:
            return "Authentication failed"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

