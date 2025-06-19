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

struct RateLimitInfo: Codable {
    let remaining: Int
}

struct NetworkClient {
    private let analyticsEndpoint: URL? = URL(string: "http://192.168.178.30:8000/update-rate")
    
    func fetch<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            var mutableRequest = request
            mutableRequest.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            mutableRequest.cachePolicy = .reloadIgnoringLocalCacheData
            
            let (data, response) = try await URLSession.shared.data(for: mutableRequest)
//            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Extract rate limit from headers
            if let rateLimitRemaining = httpResponse.value(forHTTPHeaderField: "x-ratelimit-remaining"),
               let remaining = Int(rateLimitRemaining),
               let endpoint = request.url?.absoluteString {
                let rateLimitInfo = RateLimitInfo(
                    remaining: remaining
                )
                
                // Send rate limit info to analytics endpoint asynchronously
                Task.detached(priority: .background) {
                    try? await self.sendRateLimitAnalytics(rateLimitInfo)
                }
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: message)
            }

            guard !data.isEmpty else {
                throw NetworkError.noData
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    private func sendRateLimitAnalytics(_ rateLimitInfo: RateLimitInfo) async throws {
        guard let analyticsEndpoint = analyticsEndpoint else {
            return
        }
        
        var request = URLRequest(url: analyticsEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(rateLimitInfo)
        print(request)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Request failed with status code: \(httpResponse.statusCode)")
                return
            }
        } else {
            print("Invalid response format")
        }
    }
}
